using ComputabilityTheory
using Test

@time @testset "ComputabilityTheory.jl" begin
### CODING
	@test 1 ∸ 2 == 0
	@test 2 ∸ 1 == 1

    @test pair_tuple(5,7) == 83
    @test pair_tuple(5,7,20) == 5439
    @test pair_tuple([1,2,3,4,5,6,7,8,9]...) == 131504586847961235687181874578063117114329409897615188504091716162522225834932122128288032336298131
    
    @test π(83, 2, algebraic = false) == (5,7)
    @test π(83, 2, 0, algebraic = false) == 5
    @test π(83, 3, algebraic = false) == (2, 0, 7)
    @test π(1023, 2, 1, algebraic = false) == 11
    @test π(big(1315045868479612356871818745780631171143), 1, algebraic = false) == 1315045868479612356871818745780631171143
    @test π(5987349857934, 0, algebraic = false) == nothing
    @test π(83, 3) == (2, 0, 7)
    @test π(10001, 10) == (0, 0, 0, 0, 0, 0, 1, 3, 4, 9)
    @test π(big(1315045868479612356871818745780631171143), 1) == 1315045868479612356871818745780631171143
    @test π(5987349857934, 0) == nothing
    small_random = abs(rand(1:100))
    large_random = abs(rand(1:10000))
    @test π(small_random, 3) == π(small_random, 3)
    @test π(large_random, 2) == π(large_random, 2)
    @test π(972292871301644916468488152875266508938968846389326007980307063346008398713128885682044504108288931767348821063618087715644933567266540511345568504718733339523678538338052787779884557674350959673597803113281693069940562881722205193604550737455583875504348606989700013337656597740101535) == (7, 44097457325828774284791367377726710860393112311607949541420228252579855118277296197320694764257474575167892495444390648066046785424108252105160)
    # @test π(rand(1:10^1000), algebraic)
    
    @test cℤ([0,-1,1,-2,2,-3,3,-4,4]) == [0, 1, 2, 3, 4, 5, 6, 7, 8]
    @test cℤ((-1,2)) == 16
    @test cℤ((1,1)) == 12
    @test cℤ(3,4) == (6, 8)
    
    @test cℤ⁻¹([0, 1, 2, 3, 4, 5, 6, 7, 8]) == [0, -1, 1, -2, 2, -3, 3, -4, 4]
    @test cℤ(cℤ⁻¹(79)) == 79
    @test cℤ⁻¹(cℤ(-40)) == -40
    @test cℤ⁻¹(10029) == -5015
	int_random1 = rand(Int)
	int_random2 = rand(Int)
	@test cℤ(cℤ⁻¹(abs(int_random1))) == abs(int_random1)
	@test cℤ⁻¹(cℤ(int_random2)) == int_random2

### PROGRAMME
	@test GoToProgramme(121).programme_length == 1
	@test GoToProgramme(972292871301644916468488152875266508938968846389326007980307063346008398713128885682044504108288931767348821063618087715644933567266540511345568504718733339523678538338052787779884557674350959673597803113281693069940562881722205193604550737455583875504348606989700013337656597740101535).programme_length == 7
	
	io = IOBuffer()
	show_programme(io, 121)
	@test occursin(r"0[[:space:]]*halt", String(take!(io)))
	
	io = IOBuffer()
	show_programme(io, 972292871301644916468488152875266508938968846389326007980307063346008398713128885682044504108288931767348821063618087715644933567266540511345568504718733339523678538338052787779884557674350959673597803113281693069940562881722205193604550737455583875504348606989700013337656597740101535)
	@test occursin(r"6[[:space:]]*halt", String(take!(io)))

### INSTRUCTIONS
	@test Instruction(7).instruction == (1, 2)
	@test Instruction(7).first == 1
	@test Instruction(7).second == 2
	@test Instruction(7).third == nothing
	@test Instruction(58).second == 1
	@test Instruction(58).third == 2
	@test Instruction((3, (1, 2))).I == 58
	@test Instruction((3, 1, 2)).I == 58
	@test Instruction(3, 1, 2).I == 58
	@test Instruction(4, 0).I == 14

	@test run_goto_programme(121) == tuple(0)
	@test run_goto_programme(363183787614755732766753446033240, RegisterMachine(1, 2, 3)) == tuple(2, 1, 3)
	@test run_goto_programme(972292871301644916468488152875266508938968846389326007980307063346008398713128885682044504108288931767348821063618087715644933567266540511345568504718733339523678538338052787779884557674350959673597803113281693069940562881722205193604550737455583875504348606989700013337656597740101535, (3, 1, 1)) == tuple(4, 0, 1)
	@test run_goto_programme(223927124717252638681796127568111496742698512180714163023526568831822132049774230195118493600338381851704911289089017787857413597404988541338847992210485499035130781598573348126975813033599979584118468386578559370872281223796019975651453204160222340161200928955988080303016030336930443304245145601448154569733221264381538305168568931449480758528673246332402357557389885850502823987502500615923705666157574953869234044687656342114443578201036399996781757409020565065471713601342262949677684562201881239545438799475865994538241042725394500589505167297761345293434717297622500387774051925726286270828011593028154888482643933182720230237091007716467114407940246910876104242298811097230924566373379040422996695018496814405564315525869126758556165426204979060785448299907433924693776629082547220185023385651497716000521725878783901307004251127081977484444374187001323436144140037580903329365965139055311902469340438083050750301104320244848087790925135435440549816132311216931423038414958594054194345955328449597351606723033103611762253425583323756613052352836016212463541320408142893340287911691519461708609068873926465524275772411714118028019844718904105500330674632838771428681137130136100546871186789563992080600787879878511406660580151025959186841418554827311891320184308989618516409485943704466045877998837588192158884659614365477933514118459878126838662936672543012162679280965785850875755241288227892173373302073145637378088093219495972690064022128760997033867243024673762202229065063901594672092113076799336225728489852391219624477091216808040617586878843148705687256752473769380170895833165256985381066579262059980097322456692517960764426357076378502591620840598428480692392558582556549972917361099374457224379447165159150577431975140314355645616431652416541261437750090494682945620970384916782903782096424825827978169475334019068642656156261072845169384253772103615589882161531092319774765872915674167557806826727743079891261233740545808889798017329652560892724042630851029267797497619411669453984450602449597986084188806823478595595515128790674171852156626442453849830854084257473658507273475076486871236759558604076795418209173234381881185600648269038607854092549797177142124163026021172162187852101251819011578114092027496262838478199601979508935066069585104555431366780222617619635159394639488403252338359673576720653539411491577093278404645966204761032796579698188013739359885785188427988372869573092916550596059755937168888105513627640203861038587598828520438054944864945385514172661237373005642977222691283341092758484095459330166556676864303459850601868153088510594207374543818165331580579808638399043608636650159746931808355843721671440780553546753959760350975906249580764849993052921544867678610217996851589828713473915270585295877597236593571404899502354444405479601753716517182781778676830983428681476532848100787997408528892345104613523387370533475767447648602910646760355660958540505065155007961785878896275786367616723562594625648464444056163755337577182731373365691826878791057479596578563844746371661) == tuple(1, 0)
	
	# Basically all we can test with rand is that the output has a halting instruction in the correct place
	io = IOBuffer()
	show_programme(io, rand(GoToProgramme, 3))
	@test occursin(r"[[:digit:]][[:space:]]*halt", String(take!(io)))
	io = IOBuffer()
	show_programme(io, rand(GoToProgramme, 11))
	@test occursin(r"[[:digit:]][[:digit:]][[:space:]]*halt", String(take!(io)))
end # end testset