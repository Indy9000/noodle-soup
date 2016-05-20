#r "node_modules/fable-core/Fable.Core.dll"

open Fable.Core
open Fable.Import.Browser

[<Emit("Math.random()")>]
let random (): float = failwith "JS only"
[<Emit("Math.PI")>]
let PI:float = failwith "JS only"

[<Emit("getData($0,$1)")>]
let getData(x:int)(y:int):string = failwith "JS only"

[<Emit("getDataLength()")>]
let getDataLength():int = failwith "JS only"

let getRandomFloat min max = random() * (max-min) + min
let getRandomInt (min:int) (max:int) = (getRandomFloat (float min) (float max))|> floor |> int
let fromPolar (v:float,theta:float) = ((v*cos theta),(v*sin theta))

//----------------------------------------------------------------------------------
let Count = 100 // Element count
let maxBrushSize = getRandomFloat 3. 12.
let maxBrushDelta = 0.5
let W = 640.
let H = 480.
let dW = 300.
let dH = 240.
let maxDbs = getRandomFloat 0.01 (maxBrushSize/4.)
let canvas =  document.getElementsByTagName_canvas().[0]
canvas.width <- W
canvas.height <- H
let x_mid = (H /2.0)
let y_mid = (W/2.0)
let Count_Change = getRandomInt 50 300
let Count_Stop = 3000
//----------------------------------------------------------------------------------

let len = getDataLength();
let palette_id = getRandomInt 0 len
let Colors = Array.init 5 (fun i-> getData palette_id i)
    
type GElement ={
    x:float; y:float;
    x_:float; y_:float; //old values
    v:float; theta:float;
    brushSize:float;color:string
}

let createElement() =
    let xx = getRandomFloat 0. W;
    let yy = getRandomFloat 0. W;
    {
        x = xx; x_ = xx;
        y = yy; y_ = yy;
        v = getRandomFloat 1.0 3.0;
        theta = getRandomFloat 0.0 (2.0*PI);
        brushSize = getRandomFloat 0.05 maxBrushSize;
        color = Colors.[(getRandomInt 1 5)]; 
    }
        
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
         
let elements = Array.init Count (fun a-> createElement()) 

let draw (ctx:CanvasRenderingContext2D) (el:GElement)=
    ctx.fillStyle <- U3.Case1 (el.color)
    ctx.fillRect(el.x,el.y,el.brushSize,el.brushSize)
    el

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
        
let rec update els count ()=
    let ctx = canvas.getContext_2d()
    
    let els_ = els |> Array.map(fun el->
                        (if count % Count_Change = 0 then
                            createElement()
                        else
                            (updateElement el)
                        )   
                        |> draw2 ctx //draw
                     )
        
    //wait and repeat
    if count >= Count_Stop then ()
    else
        window.setTimeout(update els_ (count + 1), 1000./60.) |> ignore
    
let drawText x y t = 
   let ctx = canvas.getContext_2d()
   ctx.fillStyle <- U3.Case1 "#FFF"
   ctx.font <- "12px monospace"
   ctx.fillText(t,x,y)
   
let main() =
    let ctx = canvas.getContext_2d()
    ctx.fillStyle <- U3.Case1 (Colors.[0])
    ctx.fillRect(0.,0.,W,H)
    update elements 0 () 

//go forth
main()
