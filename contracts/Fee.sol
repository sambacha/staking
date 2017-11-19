pragma solidity ^0.4.18;


import './SafeMath.sol';
import './Owned.sol';
import './Validating.sol';
import './StandardToken.sol';


/**
  * @title FEE is an ERC20 token used to pay for trading on the exchange.
  * For deeper rational read https://leverj.io/whitepaper.pdf.
  * FEE tokens do not have limit. A new token can be generated by owner.
  */
contract Fee is Owned, Validating, StandardToken {

  /* This notifies clients about the amount burnt */
  event Burn(address indexed from, uint256 value);

  string public name;                   //fancy name: eg Simon Bucks
  uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
  string public symbol;                 //An identifier: eg SBX
  uint256 public feeInCirculation;      //total fee in circulation
  string public version = 'F0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.
  address public minter;

  modifier onlyMinter {
    require(msg.sender == minter);
    _;
  }

  /// @notice Constructor to set the owner, tokenName, decimals and symbol
  function Fee(
  address[] _owners,
  string _tokenName,
  uint8 _decimalUnits,
  string _tokenSymbol
  )
  public
  notEmpty(_tokenName)
  notEmpty(_tokenSymbol)
  {
    setOwners(_owners);
    name = _tokenName;
    decimals = _decimalUnits;
    symbol = _tokenSymbol;
  }

  /// @notice To set a new minter address
  /// @param _minter The address of the minter
  function setMinter(address _minter) external onlyOwner validAddress(_minter) {
    minter = _minter;
  }

  /// @notice To eliminate tokens and adjust the price of the FEE tokens
  /// @param _value Amount of tokens to delete
  function burnTokens(uint _value) public notZero(_value) {
    require(balances[msg.sender] >= _value);

    balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
    feeInCirculation = SafeMath.sub(feeInCirculation, _value);
    Burn(msg.sender, _value);
  }

  /// @notice To send tokens to another user. New FEE tokens are generated when
  /// doing this process by the minter
  /// @param _to The receiver of the tokens
  /// @param _value The amount o
  function sendTokens(address _to, uint _value) public onlyMinter validAddress(_to) notZero(_value) {
    balances[_to] = SafeMath.add(balances[_to], _value);
    feeInCirculation = SafeMath.add(feeInCirculation, _value);
    Transfer(msg.sender, _to, _value);
  }
}
