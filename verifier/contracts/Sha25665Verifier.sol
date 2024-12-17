// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./ITask.sol";
import "./IVerifier.sol";

contract Sha25665Verifier is Initializable, OwnableUpgradeable, ERC165, IVerifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay  = 9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1  = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2  = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1  = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2  = 10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 19309556518108858645536395059821634797449978845358238069438937447157978844108;
    uint256 constant deltax2 = 12842970131309526144039444772935552958093761520288765017739709741710367117386;
    uint256 constant deltay1 = 13014725902324273530747005136286787654938111264958430593885765763016646944819;
    uint256 constant deltay2 = 20653906503973678778422510957173561766969200123963209065477699952723512620565;

    
    uint256 constant IC0x = 3807511589158653073981804682428484964773204905931306613802478032211987840731;
    uint256 constant IC0y = 3393217445967211934609679449504333941311150113737969487039024853019067138727;
    
    uint256 constant IC1x = 15996950574162128226208053891514578810348647681161007245984277929655606587043;
    uint256 constant IC1y = 2797191367197300326527865545859002931391592245270783630542219330535551204117;
    
    uint256 constant IC2x = 17187413817306103377477152443450096549444250489989658440494514386872921606002;
    uint256 constant IC2y = 16324402374324444842551740053251531083402520990654594104561184251144233659181;
    
    uint256 constant IC3x = 10875106279021670915785971517742255343971591853297636272122285109049606071507;
    uint256 constant IC3y = 3510225799813683806862413772126995052225604458088248323275560505422115017165;
    
    uint256 constant IC4x = 5776999525763602837874062936491517341483388259873076493079746129642019786494;
    uint256 constant IC4y = 9519015667083850977621511012264814800753012230087037156223205053440718211206;
    
    uint256 constant IC5x = 2482718796971737032702371131795531661658810800232544097202905599738459831357;
    uint256 constant IC5y = 18700854352189272288667657841378305812729116357650077154217340460392881286529;
    
    uint256 constant IC6x = 1737075472802917175507744919245268466435216961728064234748199067112214756716;
    uint256 constant IC6y = 18957306839710778325094955883983567217351841752164786626880502084365865526454;
    
    uint256 constant IC7x = 1476047440800120087254693676602717034513745773121746786233934778807352414098;
    uint256 constant IC7y = 19216000536422526522300113035530619796128875512946268523351942514882511774274;
    
    uint256 constant IC8x = 15589612230291787348631990012488682354925777341044550915869149624130818049938;
    uint256 constant IC8y = 16717680368147111117459991339420755715727118618797014280155552777513378127831;
    
    uint256 constant IC9x = 1843690037615196835353853144023617060018873648676563552356148925563022205993;
    uint256 constant IC9y = 20962485813008519382831134756917544697125924698470538223688537170771539466983;
    
    uint256 constant IC10x = 15359436341196875177818678275758945928713801855707083194950174092809560549774;
    uint256 constant IC10y = 3213020464200405876675374448973498222239199475720083358799985786623692173383;
    
    uint256 constant IC11x = 875212564467710878339791676634531030195383164553114772892367361362672375372;
    uint256 constant IC11y = 6466821922044104646581385312870924638943928380009124867242225883847041460857;
    
    uint256 constant IC12x = 3840679584410151151157000276564193641241054215675285212103880101086290804630;
    uint256 constant IC12y = 15629477859247115695205839037658404244780170681100853814881249082148188492062;
    
    uint256 constant IC13x = 12932671093289655256535229999519337880432048009656150423917061985767040335740;
    uint256 constant IC13y = 18880785356476297986406397467327555919745878355316511017668314208822892589326;
    
    uint256 constant IC14x = 17586050195938174774958420628334314708787515149790979684053281764758872521622;
    uint256 constant IC14y = 16344029689052705289098662890395736729096298111135852973590896120365799761712;
    
    uint256 constant IC15x = 18422084990659263121077544890345169145062022883471582494453673697168756253857;
    uint256 constant IC15y = 15080419011584837254198692992669359983966440379319116850404506205915775472406;
    
    uint256 constant IC16x = 13705953666183568554314005342748315297173735976226656938593003800125174107742;
    uint256 constant IC16y = 19349088018309218764976867635276040016091055797477014748195177044257263067173;
    
    uint256 constant IC17x = 1549561290055190077248096227677955269931989586138611600054065776696865029246;
    uint256 constant IC17y = 19874486187891352031575700388798617567224023063126393398335352293646833914827;
    
    uint256 constant IC18x = 10518866163631065317955813595775524739623570346427673541363519028030154784269;
    uint256 constant IC18y = 4559872678630631773781205346925030084833304173984649419005361600979737247700;
    
    uint256 constant IC19x = 1815955557315932556390406726966752368286075853346238888751839869018297044858;
    uint256 constant IC19y = 8072693838782801987186936106903320934357905085322820042211888374770350142085;
    
    uint256 constant IC20x = 14933377610256245722134263867056419065715837226889636658354601742409001069082;
    uint256 constant IC20y = 2974619205051623285239621025932861520482758646418457769253728636822249922094;
    
    uint256 constant IC21x = 7714721946528460196671065028348138523813999340010194803715213384574387273973;
    uint256 constant IC21y = 15138552770977159361656886913700237709484714546868934857252719806111775920299;
    
    uint256 constant IC22x = 2447942357915556432801217900770435948065604310912958490609514500271668938053;
    uint256 constant IC22y = 20821706524763543602765149104025146247837152415796911546111266371011182212091;
    
    uint256 constant IC23x = 16693782653688971505990117501026901918820993371328253280679186318799042143493;
    uint256 constant IC23y = 5896537750267844247405360494459517324370055257295835836957735531127480399924;
    
    uint256 constant IC24x = 10489605764514365870798864466436803296883799850353921702832080907537172440519;
    uint256 constant IC24y = 14539988904818260113247451765761815209246585672003138878145357172090997766079;
    
    uint256 constant IC25x = 11149640125466878899088602333758090342835805889855928256603471995953356224606;
    uint256 constant IC25y = 8218613179780882841407361744005908594970635054130858185615028806824565909807;
    
    uint256 constant IC26x = 18262979103699795845937216407656244369875118312836876663247853105089951227337;
    uint256 constant IC26y = 17255822505730642591003457441819450496264307725831564354920013637062424905875;
    
    uint256 constant IC27x = 11473296062950959695902260051395988596867613959649113030198206676626217106778;
    uint256 constant IC27y = 13927357044960011419958661422224353910408284711270319086639166159840054588605;
    
    uint256 constant IC28x = 1903767644002351976718845926750182845393694945364658085697175699427621538652;
    uint256 constant IC28y = 3820259219354638425194187960699451266080626066979827855769702108043525128639;
    
    uint256 constant IC29x = 15877159017007836514587719570584058766741312445030220622657484517375298982628;
    uint256 constant IC29y = 6565185171698337897949271903432333356969391101639711101169678272469645620893;
    
    uint256 constant IC30x = 21397505505163856570647681085571643335513466971844037186036247926044643288671;
    uint256 constant IC30y = 12121030374840486369504486568965160303797789622831509766154780541750559121179;
    
    uint256 constant IC31x = 14444504139530591433196000382411284095236910567607596435022908273097627957718;
    uint256 constant IC31y = 15223882601642674089804718769009130736956573647157689828566556754781366452274;
    
    uint256 constant IC32x = 2825242410975583957557037251005911725010506678234816891080371819495243985186;
    uint256 constant IC32y = 21312339554115861678243571522353763568730743170759178150082621283132333730306;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    /// admin list for register account
    mapping(address => bool) public allowlist;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IVerifier).interfaceId || super.supportsInterface(interfaceId);
    }

    function name() external pure returns (string memory) {
        return "Competition-2";
    }

    function permission(address sender) external view returns (bool) {
        return allowlist[sender];
    }

    /// show how to serialize/deseriaze the inputs params
    /// e.g. "uint256,bytes32,string,bytes32[],address[],ipfs"
    function inputs() external pure returns (string memory) {
        return "bytes32";
    }

    /// show how to serialize/deserialize the publics params
    /// e.g. "uint256,bytes32,string,bytes32[],address[],ipfs"
    function publics() external pure returns (string memory) {
        return "bytes32";
    }

    function types() external pure returns (string memory) {
        return "zk";
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    function allow(address account, bool _allow) external onlyOwner {
        allowlist[account] = _allow;
    }

    struct Proof {
        uint[2] _pA;
        uint[2][2] _pB;
        uint[2] _pC;
    }

    function verify(bytes calldata _publics, bytes calldata _proof) external view returns (bool) {
        bytes32 rPublics = abi.decode(_publics, (bytes32));
        Proof memory mProofs = abi.decode(_proof, (Proof));

        uint[32] memory mPublics;
        for (uint256 i = 0; i < 32; i++) {
            mPublics[i] = (uint8(rPublics[i / 8]) >> (7 - i % 8)) & 1;
        }

        return this.verifyProof(mProofs._pA, mProofs._pB, mProofs._pC, mPublics);
    }

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[32] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
