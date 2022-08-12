pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//interfaz de token
interface IERC20{

    //suply tokens
    function totalSupply() external view returns(uint256);

    //devuelve cantidad de tokens para una address
    function balanceOf(address account) external view returns(uint256);

    //Devuelve el numero de tokens que el owner podrá gastar
    function allowance(address owner, address emisor) external view returns(uint256);

    // resultado booleano de la operacion
    function transfer(address receptor, uint amount) external returns (bool);

    //valor booleano del resultado de la operacion de gasto
    function approve(address emisor, uint amount) external returns(bool);

    //devuelve un valor booleano del return de la operacion de paso de una cantidad con allowance
    function transferFrom(address emisor, address receptor, uint256 num) external returns(bool);

    //evento que deba emitir una transferencia de E -> R
    //event Transfer(address indexed from, address indexed to, uint256 value);

    // evento que se debe emitir cuando se estable una asignacion con allowance()
    //event Approval(address indexed owner, address indexed emisor, uint256 value);
}

//funciones del token piti
contract PITI is IERC20{

    string public constant name = "Piti";
    string public constant symbol = "PT";
    uint8 public constant decimals = 2;

    event Transfer(address indexed from, address indexed to, uint256 token);
    event Approval(address indexed owner, address indexed emisor, uint256 token);

    using SafeMath for uint256;

    mapping (address => uint) balance;
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;

    constructor (uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balance[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns(uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint256 newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balance[msg.sender] += newTokensAmount;
    } 

    function balanceOf(address tokenOwner) public override view returns(uint256){
        return balance[tokenOwner];
    }

    function allowance(address owner, address emisor) public override view returns(uint256){
        return allowed[owner][emisor];
    }

    function transfer(address receptor, uint numTokens) public override returns (bool){
        require(numTokens <= balance[msg.sender]);
        balance[msg.sender] = balance[msg.sender].sub(numTokens);
        balance[receptor] = balance[receptor].add(numTokens);
        emit Transfer(msg.sender, receptor, numTokens);
        return true;
    }

    function approve(address emisor, uint numTokens) public override returns(bool){
        allowed[msg.sender][emisor] = numTokens;
        emit Approval(msg.sender,emisor, numTokens);
        return true;    
    }
    //intermediario para vender tokens
    function transferFrom(address owner, address comprador, uint256 numTokens) public override returns(bool){
        //requiere que los tokens sean menor o igual a los que tiene el owner
        require(numTokens <= balance[owner]);
        // requiere que el numero de tokens sea menor a los que el owner permite dar
        require(numTokens <= allowed[owner][msg.sender]);

        //restamos los tokens al owner
        balance[owner] = balance[owner].sub(numTokens);
        //nos restamos los tokens como intermediarios
        allowed[owner][msg.sender] =allowed[owner][msg.sender].sub(numTokens);
        //sumamos al comprador
        balance[comprador] = balance[comprador].add(numTokens);
        //emitimos transfer
        emit Transfer(owner,comprador,numTokens);
        return true;
    }
}