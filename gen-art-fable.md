## **Generative Art Experiment with Fable**

Because robots need culture too.. II

Continuing on from the previous generative art experiment with Elm I wasn't completely happy with the flexibility offered by Elm at the moment. Problems are Canvas/Svg performance is not quite good, Random number generation at large scale can become very tedious very quickly. Also, sometime you need persistence of the drawings for effects, without having to keep a history of objects and redraw each frame. 

So the next stop was to use [Fable](http://fsprojects.github.io/Fable), another transpiler, this time from [F# / FSharp](http://fsharp.org/) to Javascript. Fable uses [Bable](https://babeljs.io/) to generate the source maps. I know it sounds like 'words with friends' but humour me. Bable is a Javascript to Javascript transpiler.. it's turtles all the way down. Here's a [place where they make a case for Bable](http://codemix.com/blog/why-babel-matters), It would be excellent if the articles that describe 'X' would describe the pros and cons of 'X'. But that utopia hasn't arrived yet.

Here are the [installation and set up instructions for Fable](http://fsprojects.github.io/Fable/docs/compiling.html) Once you have those fiddly bits sorted out, on to creating a FSharp script. Just open your code editor (VSCode,Vim, notepad etc) and create a *.fsx file. First thing to do is to sort out the references and included libs as below

```fsharp
#r "node_modules/fable-core/Fable.Core.dll"

open Fable.Core
open Fable.Import.Browser
```

With FSharp, you have to predefine everything you need. This is in contrast to other languages where the order of definitions don't matter. This is good in a way because you are sure where your dependencies are. But slight annoyance is that you would be reading the code from the bottom upwards.

```fsharp
let main() =
    let ctx = canvas.getContext_2d()
    ctx.fillStyle <- U3.Case1 (Colors.[0])
    ctx.fillRect(0.,0.,W,H)
    update elements 0 () 
```
This is the main entry point, where we set up a canvas and fill it with some colour, and call `update`.

```fsharp
let rec update els count ()=
    let ctx = canvas.getContext_2d()
    let els_ = 
	    els 
	    |> Array.map(fun el->
              (if count % Count_Change = 0 then
	               createElement()
               else
	               (updateElement el)
              )   
              |> draw2 ctx //draw
              )
        
    //wait and repeat
    if count >= Count_Stop then 
	    ()
    else
        window.setTimeout(update els_ (count + 1), 1000./60.) |> ignore

```

`update` is a recursive function which handles the main program loop.
We take a list of elements, transform each by mapping an `updateElement` function for each and draw.

```fsharp
let draw2 (ctx:CanvasRenderingContext2D) (el:GElement)=
    ctx.beginPath()
    ctx.moveTo(el.x_, el.y_)
    ctx.lineTo(el.x, el.y)
    ctx.lineWidth <- el.brushSize
    ctx.lineCap <- "round" 
    ctx.lineJoin <- "round"
    ctx.strokeStyle <- U3.Case1 (el.color)
    ctx.globalAlpha <- getRandomFloat 0.5 1.
    ctx.stroke()
    el
```

Drawing is straightforward. Each element contains positional data and brush colour and width. Using these properties, we draw a line from previous position to next.

```fsharp
let updateElement el = 
    //compute deltas
    let dbs = getRandomFloat -maxDbs maxDbs
    let dv = getRandomFloat -0.01 0.01
    let dtheta = getRandomFloat -(PI/8.0) (PI/8.0)
    let (xx,yy) = fromPolar(el.v,el.theta)
        
    let dbs = if (el.brushSize + dbs) > maxBrushSize then -dbs 
                else 
                if (el.brushSize + dbs) < 0.0 then -dbs 
                else dbs
    {//return updated element
        x_ = el.x; y_ = el.y;//save old values
        x = el.x + xx; y = el.y + yy;
        v = el.v + dv; 
        theta = el.theta + dtheta
        brushSize = el.brushSize + dbs
        color = el.color
    }

```

For updating each element, we use random delta additions within bounds for speed and direction, and brush sizes. New position is computed from the old position and the current velocity. Creating elements is similar and the element is defined as below.

```fsharp
type GElement ={
    x:float; y:float;
    x_:float; y_:float; //old values
    v:float; theta:float;
    brushSize:float;color:string
}
```

This is quite straight forward. Not only that we can use mappings for custom javascript functions. For example:

```fsharp
[<Emit("Math.random()")>]
let random (): float = failwith "JS only"

[<Emit("Math.PI")>]
let PI:float = failwith "JS only"

[<Emit("getData($0,$1)")>]
let getData(x:int)(y:int):string = failwith "JS only"

[<Emit("getDataLength()")>]
let getDataLength():int = failwith "JS only"
```

Here, `random()` function is mapped to Javascript's `Math.random()`. When you need to use function arguments such as in `getData(x:int)(y:int):string`
they are mapped to the Javascript functions arguments by `$0`, `$1` and so on.

I find this very flexible. The interoperability is amazingly simple. The full power of HTML5 canvas available from FSharp, and according to the docs, the compiled javascript is efficient as well. 

Have a look here for the real time demo


<div><canvas align="center" id="canvas" width="640" height="480"></canvas><div style="font-size:10px"></div><script src="../scripts/gen-art-fable/color-palettes.js"></script><script src="../scripts/gen-art-fable/core.min.js"></script><script src="../scripts/gen-art-fable/require.js"></script><script>requirejs.config({baseUrl:"../scripts/gen-art-fable",paths:{"fable-core":"fable-core.min"}}),requirejs(["gen-art"]);</script><button onclick="location.reload()">Reload to Randomize</button></div>




>Code on github (https://github.com/Indy9000/noodle-soup)