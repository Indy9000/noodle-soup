## **Generative Art Experiment with Elm**

Because robots need culture too..

I was quite inspired by computational art presented by https://color-wander.surge.sh . This is reminicent of the demo scene I used to follow and be amazed back in the day. But having these run in a browser makes it so accessible. So I decided to have a bash at it knowing that if this works successfully, I could use some of the techniques to my simulations and artificial life experiments.

I've used TypeScript before for some simulations and found it to be a massive improvement on Javascript. But here I was more interested in finding out if functional programming could be a good fit. As such, I've first used [#elm-lang](https://twitter.com/search?q=%23elmlang) as it is a quite minimal and fun purely functional language that transpile to javascript based on Haskell. 

[Elm](http://elm-lang.org/) is evolving as we speak so the properties I've used here may change in the future. Elm has a simple Model-Controller-View pattern to all its programs. The `main` function describes the program, in 4 parts. `init` function initialises your model `view` handles the display output, `update` describes how the model is updated and `subscriptions` describe the events that the program handles. All this is beautifully explained in [The Elm Architecture](http://guide.elm-lang.org/architecture/index.html) documents.

```elm
main : Program Never
main = Html.program {
	init = init,
    view = view,
    update = update,
    subscriptions = subscriptions
}
```

Once that is done we start by defining your model. My model consists of particles that we want to animate and model definitions looks as below.

```elm
type alias Particle = {
	x:Float, y:Float,
    v:Float, theta:Float,
    brushSize:Float,
    color:String
}

type alias Model = {
    time:Time,
    seed:Seed,
    particles: List Particle,
    history:List Particle
}
```

So a Particle as the positional properties (x,y) and a velocity (v) and and angle (theta). Also a brush size and the colour of the brush for drawing pretty bits. 

Model consists of a list of Particles and some auxiliary properties for house keeping. Then we can define functions to initialise the model and each particle. This looks as below.

```elm
init:(Model,Cmd Msg)
init =
	let 
	(els,s1) = initParticles particleCount (Random.initialSeed 42)
    model = {
	    time = 0.0,
        seed = s1,
        particles = els,
        history = []
    }
    in
    (model, Cmd.none)
```

Elm forces you to think about what you want to do, before actually jumping into it. Above as you can see, the function declaration precedes the function definition. `init` takes no parameters and returns a `tuple` of `Model` and a command (`Cmd`) with a parametric type `Msg` 

Local bindings are formulated in the `let` block and applied in `in` block. Creating particles need a lot of random number generation. This is one sore point of elm unfortunately. Because of the emphasis on purity, the functions don't have side effects, as such they should return the same output given the same input. 

```elm
initParticles: Int->Seed->((List Particle),Seed)
initParticles count seed =
    let
        (t,s1) = Random.step (list count (float 0 (2*pi))) seed
        (v,s2) = Random.step (list count (float 1 2)) s1
        (b,s3) = Random.step (list count (float 0.01 0.3)) s2
        (c,s4) = Random.step (list count (int 1 5)) s3
    in
        ((List.map4 initParticle t v b c),s4)
```

`Random.step` function generates the random number(s) and also return a new `seed`. And this `seed` has to be passed to the next random number generator. This weaving of the `seed` through is quite cumbersome.

Updating the model is done in the `update` function and it requires a `Msg` and a `Model` and returns a `Model` and a `Cmd` parameterised by a `Msg`.

```elm
type Msg = Tick Time

update : Msg -> Model -> (Model,Cmd Msg)
update action model =
    case action of
        Tick newTime -> updateModel newTime model
```
The whole update cycle is driven by the timer that we subscribe to as shown below. It takes in a `Model` and returns a subscription of `Msg` type. `update` function above handles the timer tick event message and updates the model. The wiring up of the messages passing is done by the elm framework.

```elm
subscriptions : Model -> Sub Msg
subscriptions model = 
    Time.every (Time.millisecond * 50) Tick
```

Finally once the update had been handled, the model is passed on to the view handler.

```elm
view: Model -> Html Msg
view model =
    let
        history = List.map draw model.history
        particles = List.map draw model.particles
    in
        svg [viewBox "0 0 640 480",width "640px"]
            (
                [rect 
	                [ x "0", y "0", 
		                width "640", height "480",fill "#69D2E7"] 
		                []
		            ] ++
                history ++
                particles
            )

draw: Particle ->Svg e
draw el =
    let 
        cx_ = toString el.x
        cy_ = toString el.y
        r_  = toString el.brushSize
    in
        circle [ cx cx_, cy cy_, r r_, fill el.color ] []

```
`view` function draws all the particles on to an `svg` html element. All HTML elements are defined as an element with a list of attributes and a list of children. Here `svg` has attributes `viewbox` and `width` and has a list of children. The children are the shapes we want it to draw on the page.


Click the button below to run the code.


<div>
<script type="text/javascript" src="../../noodle-soup/gen-art.js"></script>
<div id='fhf'></div>
<button onclick="Elm.Main.embed(fhf)">Run</button>
</div>


>Code on github (https://github.com/Indy9000/noodle-soup)