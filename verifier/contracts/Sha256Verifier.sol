// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./ITask.sol";
import "./IVerifier.sol";

contract Sha256Verifier is Initializable, OwnableUpgradeable, ERC165, IVerifier {
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
    uint256 constant deltax1 = 17137294183715025492345528431394237446869614925914089847844056211294483357155;
    uint256 constant deltax2 = 16602185398833826436083042946799722450916594341077958461919078701615463353366;
    uint256 constant deltay1 = 15721471366988514689151997183461512487330446493640378403344437673095271083790;
    uint256 constant deltay2 = 3000773424104682224174118740105327069482028428191785522932999047944663200702;

    
    uint256 constant IC0x = 1025157828154004684746605585440567401201646276036311952712134686053136326556;
    uint256 constant IC0y = 816941902115386850085520987316679296225953356434168255233172672738520373311;
    
    uint256 constant IC1x = 12500961588224208220510212670999986834207291442599409263135676136672733005929;
    uint256 constant IC1y = 16510900377813114495949409026992266642834617767889447301138292852304430899052;
    
    uint256 constant IC2x = 4405635250690386210095538748879090825008399616202572861001940725820420399206;
    uint256 constant IC2y = 7500592639147915271828588224806981648642997686418488276738387184473917228070;
    
    uint256 constant IC3x = 12504127760751228238061392529463576995667570884077014919153865937051848105892;
    uint256 constant IC3y = 17493884209430143130945438090426187280284981999102861649455954102483908544804;
    
    uint256 constant IC4x = 13433431198073906287326489233097078212026358857724551386113685874263295244929;
    uint256 constant IC4y = 9312991825890986809572207070533805047274593706891589592285368592614626777747;
    
    uint256 constant IC5x = 1136901620121265909427999049856370660941056078167288674942866337111256737700;
    uint256 constant IC5y = 18954486780031107642004723250277072232243587413683050992075306229303949070275;
    
    uint256 constant IC6x = 4985157452462395193826065451186050695107788308489124512741122039214899289511;
    uint256 constant IC6y = 15330365235587119570157775039174118331430788834258043466774047718594911246189;
    
    uint256 constant IC7x = 19476120029398496470002402108289223927906164149171254721141750146427510400558;
    uint256 constant IC7y = 16725411037865523576377546717875842172481765154699051752518338224763373566966;
    
    uint256 constant IC8x = 15377765437812250029019476668634287788513985419162055643112104756586690825497;
    uint256 constant IC8y = 9163107722112093730432614376613258860478111098197883010521758811554375618142;
    
    uint256 constant IC9x = 9939159554974578224459717452038386116714232434803598262286400469696028999084;
    uint256 constant IC9y = 20112117669716455864054680937772268568377771059848158256153061536101182536615;
    
    uint256 constant IC10x = 15226861997757047018629215729348648150606362042425227039839509213455095457552;
    uint256 constant IC10y = 19729674973640078405568172430474845862122277648470818640428181211077375690404;
    
    uint256 constant IC11x = 14716325565821215731127941515692421848299590653808561288378129201923521626622;
    uint256 constant IC11y = 20897534669607655824489042067035584500951648964347959426238814835154377331646;
    
    uint256 constant IC12x = 8015670062159180688021109041454060285609263654607985975944560084285323555438;
    uint256 constant IC12y = 665212920836183621696034071828421281850598323268588804809969164964607715648;
    
    uint256 constant IC13x = 6806050643461344058115607983159501589565987744579190320740640372372690275278;
    uint256 constant IC13y = 13670763261404821371564572940512345357282880655316458144225233237003473084506;
    
    uint256 constant IC14x = 4205963727016289764773935476317417204733802431954655726356512605080635779042;
    uint256 constant IC14y = 10130750380324286041170455433943345210548832169889664368331573567734781918993;
    
    uint256 constant IC15x = 18957459956336232225940501873833588567249499882371538033816255539239762324917;
    uint256 constant IC15y = 18426721292319951517320178043203589639978671542322382344545857726981387255057;
    
    uint256 constant IC16x = 13624020738108964421729159304266142740316427665684292854476678765419978800990;
    uint256 constant IC16y = 14774895958589828645674855611242145828758304324244317582876233732992669898779;
    
    uint256 constant IC17x = 1558327972653759583034877147046490995117395725474149272508066005293491139519;
    uint256 constant IC17y = 15600138619414900984091905228923604598994457066086693869561341544914964413272;
    
    uint256 constant IC18x = 3884989109298362598404366560979680830409978041931004922967350526913103601827;
    uint256 constant IC18y = 19426514047825507370751635405740131075994757877208904172998399334743621399103;
    
    uint256 constant IC19x = 17765518673157013321113812134599215173352914250323623602315812962403256333903;
    uint256 constant IC19y = 17883227603535844973984319207471435514448680908931473527452043177050757444089;
    
    uint256 constant IC20x = 9825057907008256659295745362790979576901405299690024919298900684768894336692;
    uint256 constant IC20y = 19630318221494900648889296678829973060283324081928034032830686502353983295136;
    
    uint256 constant IC21x = 16123891276053033492752342704198755026078029850893479704711896320498887227840;
    uint256 constant IC21y = 14666132101317660662099974640763687591200845764175586786733724189361407852383;
    
    uint256 constant IC22x = 17194491212591111692468537145743814782686252735279988735113277309677053048670;
    uint256 constant IC22y = 7483814285377324464089774323551124134610867032318474007888389620455427199621;
    
    uint256 constant IC23x = 13582127148804887424538185831189092422826118808498080816738512857241310456067;
    uint256 constant IC23y = 18312650719191944072179570165844758059114760207292508854825939995887511789405;
    
    uint256 constant IC24x = 14438761573529450507927575062164362207404846192364147704076892070896597438220;
    uint256 constant IC24y = 3676333250181275660122228038706741512355608199357422134573009268879211638223;
    
    uint256 constant IC25x = 21122145125736745156005815185926507577674900067691129397858986925560012701629;
    uint256 constant IC25y = 8463257796736944482418123375343576944485385544482658615430362357296716049816;
    
    uint256 constant IC26x = 18453060172559482109100013193663873990897665870704065228478840466797566604682;
    uint256 constant IC26y = 16305345257517245926266403152731759255740192522275708085422912401281273345768;
    
    uint256 constant IC27x = 15588797088503718633951872427678669925848158668643252561155585325692828958052;
    uint256 constant IC27y = 10725153372994343270068779248774881805606370687321488305271093105830136234009;
    
    uint256 constant IC28x = 5092429946403059403821198918288359917917354245946849854218910202410774990017;
    uint256 constant IC28y = 1383883072784514753107736512511036714393330572524602049484544600738816319379;
    
    uint256 constant IC29x = 11843279373475252319401459623860696737887173750975303267092089389306338787243;
    uint256 constant IC29y = 1669971179104660925267801955536360780042574922101552172500096619877845975437;
    
    uint256 constant IC30x = 17364569127794709285298725242387792661318819152920467712340618128917076831154;
    uint256 constant IC30y = 18190400529404240465904489403064385086402571709760226105570393935240828715141;
    
    uint256 constant IC31x = 8365161704781993757504582789510300121796650774329135459464923761166971599116;
    uint256 constant IC31y = 13781077023538435894537851730401096154864618399592754073996509316323841613831;
    
    uint256 constant IC32x = 19741853837745605348197573717950493666727438571770336425488175054233894918760;
    uint256 constant IC32y = 15848171138983482608131174811788255377223309729199353746447126767034099591414;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    address public task;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IVerifier).interfaceId || super.supportsInterface(interfaceId);
    }

    function name() external pure returns (string memory) {
        return "Competition-1";
    }

    function permission() external pure returns (bool) {
        return true;
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

    function initialize(address _task) public initializer {
        __Ownable_init(msg.sender);
        task = _task;
    }

    function setTask(address _task) external onlyOwner {
        task = _task;
    }

    function create(bytes calldata inputs, bytes calldata publics) external onlyOwner {
        ITask(task).create(address(this), owner(), 0, inputs, publics);
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
