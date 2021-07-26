import Control.Monad (liftM2)
import Data.Function
import qualified Data.Map as M
import Data.Maybe
import Data.Monoid
import Graphics.X11.ExtraTypes.XF86
import System.IO
import XMonad
import qualified XMonad.Actions.CycleWS as C
import XMonad.Actions.DynamicWorkspaceGroups
import XMonad.Actions.NoBorders
import XMonad.Actions.WithAll
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Prompt
import XMonad.Prompt.Shell
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

myTerminal = "alacritty"

myGruvboxTerminal = "alacritty --config-file ~/.config/alacritty/alacritty-gruvbox.yml"

myFont = "xft:Iosevka Nerd Font:weight=regular:pixelsize=16:antialias=true:hinting=true"

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

ignoredWorkspaces = ["NSP"]

-- Key bindings
myKeys =
  coreKeys
    ++ controlKeys
    ++ cycleWSKeys
    ++ dynamicWSGroupKeys
    ++ layoutKeys
    ++ scratchPadKeys
    ++ screenLayoutKeys
    ++ wmKeys
  where
    coreKeys =
      [ ("M-S-<Return>", spawn myGruvboxTerminal),
        ("M-S-n", spawn myTerminal),
        ("M-S-f", spawn "firefox --private-window"),
        ("M-S-g", spawn "brave --incognito"),
        ("M-f", spawn "firefox"),
        ("M-g", spawn "brave"),
        ("M-p", shellPrompt myPromptConfig),
        ("M-/", spawn "firefox --private-window https://vim.rtorr.com")
      ]

    controlKeys =
      [ ("<XF86AudioMicMute>", spawn "pactl set-source-mute 1 toggle"),
        ("<XF86AudioMute>", spawn "pactl set-sink-mute 0 toggle"),
        ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10"),
        ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 10"),
        ("M-<Print>", spawn "scrot -q 100 ~/Pictures/Screenshots/screen-%Y-%m-%d-%H-%M-%S.png" `withNotification` Message Critical "Screenshot" "Saved screen capture!"),
        ("M-C-<Print>", spawn "scrot -u -q 100 ~/Pictures/Screenshots/window-%Y-%m-%d-%H-%M-%S.png" `withNotification` Message Critical "Screenshot" "Saved window capture!"),
        ("M-S-<Print>", spawn "scrot -s -q 100 ~/Pictures/Screenshots/area-%Y-%m-%d-%H-%M-%S.png")
      ]

    cycleWSKeys =
      [ ("M-C-<Tab>", toggleWS),
        ("M-C-S-h", C.shiftPrevScreen),
        ("M-C-S-j", C.shiftToNext),
        ("M-C-S-k", C.shiftToPrev),
        ("M-C-S-l", C.shiftNextScreen),
        ("M-C-h", C.prevScreen),
        ("M-C-j", nextWS),
        ("M-C-k", prevWS),
        ("M-C-l", C.nextScreen)
      ]

    dynamicWSGroupKeys =
      [ ("M-M1-1", viewWSGroup "1"),
        ("M-M1-2", viewWSGroup "2"),
        ("M-M1-3", viewWSGroup "3"),
        ("M-M1-4", viewWSGroup "4")
      ]

    layoutKeys =
      [ ("M-t", withFocused $ toggleFloat $ vertRectCentered 0.9),
        ("M-S-t", withFocused $ toggleFloat $ rectCentered 0.9)
      ]

    scratchPadKeys =
      [ ("M-<F1>", openScratchPad "htop"),
        ("M-<F2>", openScratchPad "mixer"),
        ("M-<F3>", openScratchPad "ranger"),
        ("M-<F4>", openScratchPad "slack"),
        ("M-<F5>", openScratchPad "telegram"),
        ("M-`", openScratchPad "terminal")
      ]

    screenLayoutKeys =
      [ ("M-S-<F1>", spawn "~/.screenlayout/1-laptop.sh" `withNotification` notification "Laptop"),
        ("M-S-<F2>", spawn "~/.screenlayout/2-monitor.sh" `withNotification` notification "Monitor"),
        ("M-S-<F3>", spawn "~/.screenlayout/3-dual-monitor.sh" `withNotification` notification "Dual monitor")
      ]
      where
        notification msg = Message Critical "Screen layout" msg

    wmKeys =
      [ ("M-M1-c", killAll `withNotification` Message Critical "XMonad" "Killed them all!"),
        ("M-q", spawn "xmonad --recompile && xmonad --restart" `withNotification` Message Normal "XMonad" "Recompiled and restarted!")
      ]

myRemovedKeys :: [String]
myRemovedKeys =
  [ "M-S-q"
  ]

myKeysConfig :: XConfig a -> XConfig a
myKeysConfig config = config `additionalKeysP` myKeys `removeKeysP` myRemovedKeys

-- Send notification
data UrgencyLevel = Low | Normal | Critical

instance Show UrgencyLevel where
  show Low = "low"
  show Normal = "normal"
  show Critical = "critical"

data Notification
  = Message UrgencyLevel String String
  | Command UrgencyLevel String String

wrapInQuotes, wrapIntoCommand :: String -> String
wrapInQuotes = wrap "'" "'"
wrapIntoCommand = wrap "$(" ")"

sendNotification :: Notification -> X ()
sendNotification (Message uLevel summary body) = spawn ("notify-send " ++ wrapInQuotes summary ++ " " ++ wrapInQuotes body ++ " -u " ++ wrapInQuotes (show uLevel))
sendNotification (Command uLevel summary body) = spawn ("notify-send " ++ wrapInQuotes summary ++ " " ++ wrapIntoCommand body ++ " -u " ++ wrapInQuotes (show uLevel))

withNotification :: X () -> Notification -> X ()
withNotification action notification = action >> sendNotification notification

-- Layouts
defaultTall = Tall 1 0.05 0.5

tall = renamed [Replace "Default"] $ limitWindows 6 $ defaultSpacing defaultTall

monocle = renamed [Replace "Monocle"] $ defaultSpacing Full

tabbed = renamed [Replace "Tabbed"] $ noBorders $ tabbedBottom shrinkText myTabbedTheme
  where
    myTabbedTheme =
      def
        { fontName = myFont,
          activeColor = colorPalette !! 8,
          inactiveColor = colorPalette !! 1,
          activeBorderColor = colorPalette !! 8,
          inactiveBorderColor = colorPalette !! 1,
          activeTextColor = colorPalette !! 1,
          inactiveTextColor = colorPalette !! 4
        }

myLayout = avoidStruts $ tall ||| monocle

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

defaultSpacing :: l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
defaultSpacing = mySpacing 4

toggleFloat :: W.RationalRect -> Window -> X ()
toggleFloat r w = windows (\s -> if M.member w (W.floating s) then W.sink w s else W.float w r s)

-- Window rules
rectCentered :: Rational -> W.RationalRect
rectCentered percentage = W.RationalRect offset offset percentage percentage
  where
    offset = (1 - percentage) / 2

vertRectCentered :: Rational -> W.RationalRect
vertRectCentered height = W.RationalRect offsetX offsetY width height
  where
    width = height / 2
    offsetX = (1 - width) / 2
    offsetY = (1 - height) / 2

viewShift :: WorkspaceId -> Query (Endo WindowSet)
viewShift = doF . liftM2 (.) W.greedyView W.shift

htopWindowQuery :: Query Bool
htopWindowQuery = title =? "HTOP"

pulseMixerWindowQuery :: Query Bool
pulseMixerWindowQuery = title =? "PulseMixer"

rangerWindowQuery :: Query Bool
rangerWindowQuery = title =? "Ranger"

myManageHook =
  composeAll
    [ className =? "Arandr" --> customFloating (rectCentered 0.5),
      className =? "Pavucontrol" --> customFloating (rectCentered 0.5)
    ]
    <+> namedScratchpadManageHook myScratchPads
    <+> manageDocks

-- Startup hook
myStartupHook = do
  spawn "dunst"
  spawn "setxkbmap -layout us,pl,ru,ua -option grp:alt_shift_toggle"
  spawn "xset r rate 180 40"
  spawn "xsetroot -cursor_name left_ptr"
  spawn "~/.fehbg &"
  initWorkspaceGroups

-- Scratchpads
myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ htopScratchPad,
    mixerScratchPad,
    rangerScratchPad,
    slackScratchPad,
    telegramScratchPad,
    terminalScratchPad
  ]
  where
    terminalScratchPad = NS "terminal" spawn find manage
      where
        spawn = myTerminal ++ " -t Terminal"
        find = title =? "Terminal"
        manage = customFloating $ rectCentered 0.7

    rangerScratchPad = NS "ranger" spawn find manage
      where
        spawn = myTerminal ++ " -t Ranger -e ranger"
        find = rangerWindowQuery
        manage = nonFloating

    htopScratchPad = NS "htop" spawn find manage
      where
        spawn = myTerminal ++ " -t HTOP -e htop"
        find = htopWindowQuery
        manage = customFloating $ rectCentered 0.8

    mixerScratchPad = NS "mixer" spawn find manage
      where
        spawn = myTerminal ++ " -t PulseMixer -e pulsemixer"
        find = pulseMixerWindowQuery
        manage = customFloating $ rectCentered 0.5

    slackScratchPad = NS "slack" spawn find manage
      where
        spawn = "slack"
        find = className =? "Slack"
        manage = nonFloating

    telegramScratchPad = NS "telegram" spawn find manage
      where
        spawn = "telegram-desktop"
        find = className =? "TelegramDesktop"
        manage = nonFloating

openScratchPad :: String -> X ()
openScratchPad = namedScratchpadAction myScratchPads

-- Prompt config
myPromptConfig :: XPConfig
myPromptConfig =
  def
    { font = myFont,
      bgColor = head colorPalette,
      fgColor = colorPalette !! 4,
      bgHLight = colorPalette !! 8,
      fgHLight = colorPalette !! 2,
      promptBorderWidth = 0,
      position = Top,
      height = 28,
      maxComplRows = Just 5,
      showCompletionOnTab = True
    }

-- Dynamic workspace groups
addGroup :: X ()
addGroup = promptWSGroupAdd myPromptConfig "Name group: "

goToGroup :: X ()
goToGroup = promptWSGroupView myPromptConfig "Go to group: "

forgetGroup :: X ()
forgetGroup = promptWSGroupForget myPromptConfig "Forget group: "

initWorkspaceGroups :: X ()
initWorkspaceGroups = do
  addRawWSGroup "1" [(S 1, "2"), (S 0, "1")]
  addRawWSGroup "2" [(S 1, "4"), (S 0, "3")]
  addRawWSGroup "3" [(S 1, "6"), (S 0, "5")]
  addRawWSGroup "4" [(S 1, "8"), (S 0, "7")]

-- CycleWS
workspaceType :: C.WSType
workspaceType = C.WSIs $ return (\(W.Workspace tag _ stack) -> isJust stack && tag `notElem` ignoredWorkspaces)

moveTo :: Direction1D -> X ()
moveTo direction = C.moveTo direction workspaceType

nextWS :: X ()
nextWS = moveTo Next

prevWS :: X ()
prevWS = moveTo Prev

toggleWS :: X ()
toggleWS = C.toggleWS' ignoredWorkspaces

-- Main
main :: IO ()
main = do
  xMobar <- spawnPipe "xmobar ~/.xmonad/xmobar.config"
  xmonad $ docks (defaultSettings xMobar & myKeysConfig)

xmobarPrettyPrinting :: Handle -> X ()
xmobarPrettyPrinting xMobar =
  (dynamicLogWithPP . filterOutWsPP ignoredWorkspaces)
    xmobarPP
      { ppCurrent = xmobarColor' 4 . wrap "[" "]",
        ppExtras = [windowCount],
        ppHidden = xmobarColor' 13 . wrap "-" "-",
        ppHiddenNoWindows = xmobarColor' 8,
        ppLayout = \l -> xmobarColor' 4 ("\57924  " ++ l),
        ppOrder = \(ws : layout : current : extras) -> [ws, layout] ++ extras ++ [current],
        ppOutput = hPutStrLn xMobar,
        ppSep = "  ",
        ppTitle = xmobarColor' 14 . shorten 50,
        ppUrgent = xmobarColor' 11 . wrap "!" "!",
        ppVisible = xmobarColor' 14 . wrap "<" ">"
      }

xmobarColor' :: Int -> String -> String
xmobarColor' i = xmobarColor (colorPalette !! i) ""

windowCount :: X (Maybe String)
windowCount =
  gets $
    (<$>) ("\62600  " ++)
      . Just
      . show
      . length
      . W.integrate'
      . W.stack
      . W.workspace
      . W.current
      . windowset

defaultSettings xMobar =
  def
    { borderWidth = 2,
      clickJustFocuses = False,
      focusFollowsMouse = True,
      focusedBorderColor = colorPalette !! 6,
      handleEventHook = mempty,
      layoutHook = myLayout,
      logHook = xmobarPrettyPrinting xMobar,
      manageHook = myManageHook,
      modMask = mod4Mask,
      normalBorderColor = head colorPalette,
      startupHook = myStartupHook,
      terminal = myTerminal,
      workspaces = myWorkspaces
    }

-- Nord color palette
-- Each color index corresponds to color index from documentation
-- https://www.nordtheme.com/docs/colors-and-palettes
colorPalette :: [String]
colorPalette =
  [ "#2e3440",
    "#3b4252",
    "#434c5e",
    "#4c566a",
    "#d8dee9",
    "#e5e9f0",
    "#eceff4",
    "#8fbcbb",
    "#88c0d0",
    "#81a1c1",
    "#5e81ac",
    "#bf616a",
    "#d08770",
    "#ebcb8b",
    "#a3be8c",
    "#b48ead"
  ]
