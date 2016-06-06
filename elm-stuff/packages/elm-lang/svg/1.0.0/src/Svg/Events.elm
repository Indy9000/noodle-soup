module Svg.Events exposing
  ( onBegin, onEnd, onRepeat
  , onAbort, onError, onResize, onScroll, onLoad, onUnload, onZoom
  , onActivate, onClick, onFocusIn, onFocusOut, onMouseDown, onMouseMove
  , onMouseOut, onMouseOver, onMouseUp
  )

{-|

# Animation event attributes
@docs onBegin, onEnd, onRepeat

# Document event attributes
@docs onAbort, onError, onResize, onScroll, onLoad, onUnload, onZoom

# Graphical event attributes
@docs onActivate, onClick, onFocusIn, onFocusOut, onMouseDown, onMouseMove,
  onMouseOut, onMouseOver, onMouseUp

-}

import Json.Decode as Json
import Svg exposing (Attribute)
import VirtualDom



{-|-}
on : String -> Json.Decoder msg -> Attribute msg
on =
  VirtualDom.on


simpleOn : String -> msg -> Attribute msg
simpleOn name =
  \msg -> on name (Json.succeed msg)



-- ANIMATION


{-|-}
onBegin : msg -> Attribute msg
onBegin =
  simpleOn "begin"


{-|-}
onEnd : msg -> Attribute msg
onEnd =
  simpleOn "end"


{-|-}
onRepeat : msg -> Attribute msg
onRepeat =
  simpleOn "repeat"



-- DOCUMENT


{-|-}
onAbort : msg -> Attribute msg
onAbort =
  simpleOn "abort"


{-|-}
onError : msg -> Attribute msg
onError =
  simpleOn "error"


{-|-}
onResize : msg -> Attribute msg
onResize =
  simpleOn "resize"


{-|-}
onScroll : msg -> Attribute msg
onScroll =
  simpleOn "scroll"


{-|-}
onLoad : msg -> Attribute msg
onLoad =
  simpleOn "load"


{-|-}
onUnload : msg -> Attribute msg
onUnload =
  simpleOn "unload"


{-|-}
onZoom : msg -> Attribute msg
onZoom =
  simpleOn "zoom"



-- GRAPHICAL


{-|-}
onActivate : msg -> Attribute msg
onActivate =
  simpleOn "activate"


{-|-}
onClick : msg -> Attribute msg
onClick =
  simpleOn "click"


{-|-}
onFocusIn : msg -> Attribute msg
onFocusIn =
  simpleOn "focusin"


{-|-}
onFocusOut : msg -> Attribute msg
onFocusOut =
  simpleOn "focusout"


{-|-}
onMouseDown : msg -> Attribute msg
onMouseDown =
  simpleOn "mousedown"


{-|-}
onMouseMove : msg -> Attribute msg
onMouseMove =
  simpleOn "mousemove"


{-|-}
onMouseOut : msg -> Attribute msg
onMouseOut =
  simpleOn "mouseout"


{-|-}
onMouseOver : msg -> Attribute msg
onMouseOver =
  simpleOn "mouseover"


{-|-}
onMouseUp : msg -> Attribute msg
onMouseUp =
  simpleOn "mouseup"
