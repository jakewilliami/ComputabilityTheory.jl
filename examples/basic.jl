#!/usr/bin/env bash
    #=
    exec julia --project="$(realpath $(dirname $0))" --color=yes --startup-file=no -e "include(popfirst!(ARGS))" \
    "${BASH_SOURCE[0]}" "$@"
    =#

using Plots
using CSV
using DataFrames
using ProgressMeter: @showprogress
using CurveFit
using GLM

function graphing_time()
    stop_m_at = 100
    stop_n_at = 4
    num_of_datapoints = 50
    data = Matrix{Float64}(undef,num_of_datapoints,4)# needs 5 columns: n; m; bonk time; doov time; iagueqnar time
    m_data = []
    
    @showprogress for i in 1:num_of_datapoints
        n = rand(2:stop_n_at)
        m = rand(1:stop_m_at)
        bonks = @elapsed π(m, n)
        alg = @elapsed π(m, n, algebraic)
        data[i,:] .= [n, m, bonks, alg]
    end

    save_path = joinpath(dirname(@__FILE__), "unpairing", "search_v_algebraic,n=$stop_n_at,m=$stop_m_at,i=$num_of_datapoints.pdf")
    theme(:solarized)
    
    println(typeof(data[:,1]))
    println(typeof(data[:,2]))
    
    fit = curve_fit(ExpFit, data[:,1], data[:,2])
    y0b = fit.(data[:,1])
        
    plot_points = scatter(data[:,1], data[:,3:4], fontfamily = font("Times"), xlabel = "n", ylabel = "Time elapsed during calculation [seconds]", label = ["Bonk's Iterative Search" "Bonk's Algebraic Method"])#, xlims = (0, stop_n_at)) # smooth = true
    # plot = plot!(plot_points, model(1:stop_m_at, params_search))
    
    # plot = plot!(plot_points, data[:,1], data[:,2]
    plot = plot!(data[:,1], y0b, label = "model")
    savefig(plot, save_path)
    
    println("Plot saved at $save_path.")
end

function programme_ui()

	programmed_programmes = [
		121, # nothing
		5780, # increments R0
		363183787614755732766753446033240, # R0 + R1
		15064444022569784320075110954333881106157772192293890937642519911533240246282230807658733450927595112277856126952898743268714565377889514636997, # 2x
		70412762139173751174325247391799151776337005517147051043631834182952422253779831226208595923309323737831968573315841128818823056224690660136852, # halts ⟺ R0 > R1
		972292871301644916468488152875266508938968846389326007980307063346008398713128885682044504108288931767348821063618087715644933567266540511345568504718733339523678538338052787779884557674350959673597803113281693069940562881722205193604550737455583875504348606989700013337656597740101535, # relation "x is even"
		223927124717252638681796127568111496742698512180714163023526568831822132049774230195118493600338381851704911289089017787857413597404988541338847992210485499035130781598573348126975813033599979584118468386578559370872281223796019975651453204160222340161200928955988080303016030336930443304245145601448154569733221264381538305168568931449480758528673246332402357557389885850502823987502500615923705666157574953869234044687656342114443578201036399996781757409020565065471713601342262949677684562201881239545438799475865994538241042725394500589505167297761345293434717297622500387774051925726286270828011593028154888482643933182720230237091007716467114407940246910876104242298811097230924566373379040422996695018496814405564315525869126758556165426204979060785448299907433924693776629082547220185023385651497716000521725878783901307004251127081977484444374187001323436144140037580903329365965139055311902469340438083050750301104320244848087790925135435440549816132311216931423038414958594054194345955328449597351606723033103611762253425583323756613052352836016212463541320408142893340287911691519461708609068873926465524275772411714118028019844718904105500330674632838771428681137130136100546871186789563992080600787879878511406660580151025959186841418554827311891320184308989618516409485943704466045877998837588192158884659614365477933514118459878126838662936672543012162679280965785850875755241288227892173373302073145637378088093219495972690064022128760997033867243024673762202229065063901594672092113076799336225728489852391219624477091216808040617586878843148705687256752473769380170895833165256985381066579262059980097322456692517960764426357076378502591620840598428480692392558582556549972917361099374457224379447165159150577431975140314355645616431652416541261437750090494682945620970384916782903782096424825827978169475334019068642656156261072845169384253772103615589882161531092319774765872915674167557806826727743079891261233740545808889798017329652560892724042630851029267797497619411669453984450602449597986084188806823478595595515128790674171852156626442453849830854084257473658507273475076486871236759558604076795418209173234381881185600648269038607854092549797177142124163026021172162187852101251819011578114092027496262838478199601979508935066069585104555431366780222617619635159394639488403252338359673576720653539411491577093278404645966204761032796579698188013739359885785188427988372869573092916550596059755937168888105513627640203861038587598828520438054944864945385514172661237373005642977222691283341092758484095459330166556676864303459850601868153088510594207374543818165331580579808638399043608636650159746931808355843721671440780553546753959760350975906249580764849993052921544867678610217996851589828713473915270585295877597236593571404899502354444405479601753716517182781778676830983428681476532848100787997408528892345104613523387370533475767447648602910646760355660958540505065155007961785878896275786367616723562594625648464444056163755337577182731373365691826878791057479596578563844746371661, # relation "x = 3"
	]

	global programme_counter = -1
	programme_description(description::AbstractString) = (global programme_counter; programme_counter += 1; println("\t$programme_counter) $description"))

	println("The following are the list of programmes to choose from:")

	programme_description("Any ol' programme will do!")
	programme_description("A halting programme")
	programme_description("Increments R0 by one")
	programme_description("Computes R0 + R1")
	programme_description("Computes 2 × R1")
	programme_description("Halts if and only if R0 > R1")
	programme_description("Computes the relation \"x is even\"")
	programme_description("Computes the relation \"x = 3\"")

	println()
	println("Please choose a number as defined above.")

	chosen_programme = parse(Int, readline())

	println("-"^displaysize(stdout)[2], "\n")

	iszero(chosen_programme) ? test_random(rand(1:20)) : show_programme(programmed_programmes[chosen_programme])

end

function test_random(d::Integer)
    # random = abs(rand(Int)) + 121
    random = rand(121:2000)
    
    println("The programme coded by the number $random is shown in $d instructions as follows:\n")
    
    show_programme(pair_tuple(d, pair_tuple(random, pair_tuple(4, 0))))
end


# helper
function binary_search(a::BigInt, b::BigInt) # useful for bug fixing
    while a != b
        centre = BigInt(round((b + a) / 2))
        println(a, "\n", b, "\n")
        try
            π(centre, algebraic)
            a = centre
        catch
            b = centre
        end
    end
    return a
end

