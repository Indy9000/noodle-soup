import Html exposing (Html)
import Html.App as Html
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, second)
import Random exposing (..)
import Array

main : Program Never
main =
    Html.program{   
        init = init,
        view = view,
        update = update,
        subscriptions = subscriptions
    }

-------------------------------------------------------------------------------
-- Model
-------------------------------------------------------------------------------    
(simWidth,simHeight) = (600.0,400.0)
(halfWidth,halfHeight) = (300.0,200.0)
particleCount:Int
particleCount = 500

historyLength:Int
historyLength = particleCount * 10

maxBrushSize:Float
maxBrushSize = 30.0



colors : Array.Array String
colors = Array.fromList ["#69D2E7","#A7DBD8","#E0E4CC","#F38630","#FA6900"]

--type BrushKind = Circle|Square
--getParticleKind: Int -> BrushKind
--getParticleKind i =
--    if i == 0 then BrushKind.Circle else BrushKind.Square

type alias Particle =
    {   x:Float, y:Float,
        v:Float, theta:Float,
        --brushKind:BrushKind,
        brushSize:Float,
        color:String
    }

type alias Model = {
    time:Time,
    seed:Seed,
    particles: List Particle,
    history:List Particle
}

init:(Model,Cmd msg)
init = 
    let 
    (els,s1) = initParticles particleCount (Random.initialSeed 42)
    model = {
        time= 0.0,
        seed= s1,
        particles = els,
        history = []
        }
    in
    (model, Cmd.none)

initParticles: Int->Seed->((List Particle),Seed)
initParticles count seed =
    let
        (t,s1) = Random.step (list count (float 0 (2*pi))) seed
        (v,s2) = Random.step (list count (float 1 2)) s1
        (b,s3) = Random.step (list count (float 0.01 0.3)) s2
        (c,s4) = Random.step (list count (int 1 5)) s3
    in
        ((List.map4 initParticle t v b c),s4)

initParticle:Float->Float->Float->Int->Particle
initParticle t v b c = 
    let 
        cc = Array.get c colors
        col = case cc of
                Just val -> val
                Nothing  -> "#000000" 
    in 
    {
        x=halfWidth,
        y=halfHeight,
        v=v,
        theta=t,
        brushSize=b,
        color= col
    }

--initParticle = {
--    x= Random.generate (Random.float (halfWidth-10) (halfWidth+10)), 
--    y= Random.generate (Random.float (halfHeight-10) (halfHeight+10)),
--    vx=Random.generate (Random.float -3 3), 
--    vy=Random.generate (Random.float -3 3),
--    brushSize=Random.generate (Random.float 1 30),
--    --kind=getParticleKind (Random.generate (int 0 1)),
--    color = "#69D2E7"-- Array.get (Random.generate (Random.int 1 3)) colors
--    }

-------------------------------------------------------------------------------
-- Update
-------------------------------------------------------------------------------
type Msg = Tick Time

update : Msg -> Model -> (Model,Cmd Msg)
update action model =
    case action of
        Tick newTime -> updateModel newTime model

updateModel: Float -> Model -> (Model,Cmd Msg)
updateModel timeTick model=
    let
        -- generate random numbers
        count = List.length model.particles
        (v,s1) = Random.step (list count (float -0.1 0.1)) model.seed
        (t,s2) = Random.step (list count (float -(pi/8) (pi/8))) s1
        (bs,s3) = Random.step (list count (float -0.1 0.1)) s2
        particles_ = List.map4 updateParticle model.particles v t bs
        history_ = [] --manageHistory model.history model.particles
    in
        ({model| 
            time = timeTick,
            seed = s3,
            particles = particles_,
            history = history_
         }, Cmd.none)

manageHistory: (List Particle)->(List Particle)->(List Particle)
manageHistory history particles =
    let
    hlen = List.length history
    count = 5--(particleCount * 0.2)
    pruned = 
        if hlen >= historyLength then
            --List.drop (historyLength - hlen) history
            List.drop count history
        else
            history
    in
        pruned ++ particles

updateParticle: Particle->Float->Float->Float->Particle
updateParticle el v t bs=
    let
        (xx,yy) = fromPolar (el.v,el.theta)
        bs = if (el.brushSize + bs) > maxBrushSize then -bs else 
                if (el.brushSize + bs) < 0 then -bs else bs
    in
    {el|
        --v = el.v + vx_,
        theta = el.theta + t,
        x  = el.x + xx,
        y  = el.y + yy,
        brushSize = el.brushSize + bs
    }
-------------------------------------------------------------------------------
-- Subscriptions
-------------------------------------------------------------------------------
subscriptions : Model -> Sub Msg
subscriptions model = 
    Time.every (Time.millisecond * 50) Tick

-------------------------------------------------------------------------------
-- View
-------------------------------------------------------------------------------
view: Model -> Html Msg
view model =
    let
        history = List.map draw model.history
        particles = List.map draw model.particles
    in
        svg [viewBox "0 0 640 480",width "640px"]
            (
                [rect [ x "0", y "0", width "640", height "480",fill "#69D2E7"] []] ++
                history ++
                particles
            )
            --particles

draw: Particle ->Svg e
draw el =
    let 
        cx_ = toString el.x
        cy_ = toString el.y
        r_  = toString el.brushSize
    in
        circle [ cx cx_, cy cy_, r r_, fill el.color ] []
