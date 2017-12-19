/** 
 * ERC-20 Standard Token Smart Contract implementation.
 * 
 * Copyright © 2017 by {%=o.companyName%}
 * 
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * 
 * Unless required by applicable law or agreed to in writing, software 
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
 */ 

pragma solidity ^0.4.16;

{% if (o.includeApproveAndCall || o.includeTransferAndCall) { %}   
interface TokenRecipient { 
    {% if (o.includeApproveAndCall) { %}   
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public returns (bool); 
    {% } %}
    {% if (o.includeTransferAndCall) { %}   
    function tokenFallback(address _sender, uint256 _value, bytes _extraData) public returns (bool);
    {% } %}
} 
{% } %}

/** 
* ERC-20 standard token interface
*/ 
contract ERC20Interface {
    /** 
     * Get total number of tokens in circulation.
     */
    uint256 public totalSupply;
 
    /**
     * @dev Get number of tokens currently belonging to given owner.
     * 
     * @param _owner address to get number of tokens currently belonging to the owner of 
     * @return number of tokens currently belonging to the owner of given address 
     */ 
    function balanceOf (address _owner) constant public returns (uint256 balance); 

    /**
     * @dev Transfer given number of tokens from message sender to given recipient.
     * 
     * @param _to address to transfer tokens to the owner of
     * @param _value number of tokens to transfer to the owner of given address
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transfer (address _to, uint256 _value) public returns (bool success);
 
    /**
     * @dev Transfer given number of tokens from given owner to given recipient.  
     *  
     * @param _from address to transfer tokens from the owner of  
     * @param _to address to transfer tokens to the owner of  
     * @param _value number of tokens to transfer from given owner to given recipient  
     * @return true if tokens were transferred successfully, false otherwise  
     */  
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success);  
 
    /**  
     * @dev Allow given spender to transfer given number of tokens from message sender.  
     *  
     * @param _spender address to allow the owner of to transfer tokens from message sender  
     * @param _value number of tokens to allow to transfer  
     * @return true if token transfer was successfully approved, false otherwise  
     */  
    function approve (address _spender, uint256 _value) public returns (bool success);  
  
    /**  
     * @dev Tell how many tokens given spender is currently allowed to transfer from  
     * given owner.  
     *  
     * @param _owner address to get number of tokens allowed to be transferred from the owner of  
     * @param _spender address to get number of tokens allowed to be transferred by the owner of  
     * @return number of tokens given spender is currently allowed to transfer from given owner  
     */  
    function allowance (address _owner, address _spender) constant public returns (uint256 remaining);  
  
    /**  
     * @dev Logged when tokens were transferred from one owner to another.  
     *  
     * @param _from address of the owner, tokens were transferred from  
     * @param _to address of the owner, tokens were transferred to  
     * @param _value number of tokens transferred  
     */  
    event Transfer (address indexed _from, address indexed _to, uint256 _value);  
   
    /**  
     * @dev Logged when owner approved his tokens to be transferred by some spender.  
     *  
     * @param _owner owner who approved his tokens to be transferred  
     * @param _spender spender who were allowed to transfer the tokens belonging to the owner  
     * @param _value number of tokens belonging to the owner, approved to be transferred by the spender  
     */  
    event Approval (address indexed _owner, address indexed _spender, uint256 _value);  
}  
 
contract Ownable {  
    address public owner;  
    address public newOwner;  
     
    function Ownable() public {  
        owner = msg.sender;  
    }  
     
    modifier onlyOwner {  
        assert(msg.sender == owner);  
        _;  
    }  

    modifier onlyNewOwner {  
        assert(msg.sender == owner);  
        _;  
    }  
     
    /**  
     * @dev Transfers ownership. New owner has to accept in order ownership change to take effect  
     */  
    function transferOwnership(address _newOwner) public onlyOwner {  
        require(_newOwner != owner);  
        newOwner = _newOwner;  
    }  
     
    /**  
     * @dev Accepts transferred ownership  
     */  
    function acceptOwnership() public onlyNewOwner {  
        OwnerUpdate(owner, newOwner);  
        owner = newOwner;  
        newOwner = 0x0;  
    }  
     
    event OwnerUpdate(address _prevOwner, address _newOwner);  
}  

{% if (o.isPausable) { %} 
/**
* Pause/Unpanuse protection Smart Contract implementation.
*/
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

{% } %}
 
/**  
* Standard Token Smart Contract that implements ERC-20 token interface  
*/  
contract {%=o.tokenTicket%}Token is ERC20Interface, Ownable{% if (o.isPausable) { %}, Pausable {% } %}{  
    // Public variables of the token  
    string public name = {%=o.tokenName%};  
    string public symbol = {%=o.tokenTicket%};  
    uint8 public decimals = {%=o.decimalPlaces%};  
    // 18 decimals is the strongly suggested default, avoid changing it  
    uint256 public totalSupply; 

    {% if (o.isMintable) { %}
    bool public mintingFinished = false; 
    {% } %}

    {% if (o.isCapped) { %}
    /**
	 * @dev Cap for minted tokens.
	 */
	uint256 public capAmount;
    {% } %}

    // This creates an array with all balances  
    mapping (address => uint256) public balances;  
    mapping (address => mapping (address => uint256)) public allowed;  
        
    // Events
    // This generates a public event on the blockchain that will notify clients  
    event Transfer(address indexed from, address indexed to, uint256 value);  
    event ClaimTransfer(address indexed from, uint256 value);     
    {% if (o.isMintable) { %} 
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    {% } %}

    {% if (o.isCapped) { %} 
    event CapAmountIncreased(uint256 amount);
    event CapAmountDecreased(uint256 amount);
    {% } %}

    // Modifiers        
    /**  
    * Protection against short address attack  
    */  
    modifier onlyPayloadSize(uint numwords) {  
        assert(msg.data.length == numwords * 32 + 4);  
        _;  
    }  

    {% if (o.isMintable) { %} 

    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    {% } %}
        
    /**  
    * Constructor function  
    *  
    * Initializes contract with initial supply tokens to the creator of the contract  
    */  
    function {%o.tokenTicket%}Token() public {  
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount  
        {% if (o.isCapped) { %} 
        capAmount = {%=o.capAmount) { %};
        {% } %}
        balances[msg.sender] = totalSupply;                    // Give the creator all initial tokens  
    }  
        
    /**  
    * Transfer sender's tokens to a given address  
    */  
    function transfer(address _to, uint256 _value) {% if (o.isPausable) { %}whenNotPaused {% } %} onlyPayloadSize(2) public returns (bool success) {
        require(_to != 0x0);  
            
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] += _value;  
        Transfer(msg.sender, _to, _value);  
        return true;  
    }  
        
    /**  
    * Transfer _from's tokens to _to's address  
    */  
    function transferFrom(address _from, address _to, uint256 _value) {% if (o.isPausable) { %}whenNotPaused {% } %} onlyPayloadSize(3) public returns (bool success) {
        require(_to != 0x0);  
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);  
            
        balances[_from] = balances[_from] - _value;  
        balances[_to] += _value;  
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        Transfer(_from, _to, _value);  
        return true;  
    }  
        
    /**  
    * Returns number of tokens owned by given address.  
    */  
    function balanceOf(address _owner) constant public returns (uint256 balance) {  
        return balances[_owner];  
    }  
        
    /**  
    * Sets approved amount of tokens for spender.  
    */  
    function approve(address _spender, uint256 _value) public returns (bool success) {  
        require(_value == 0 || allowed[msg.sender][_spender] == 0);  
        allowed[msg.sender][_spender] = _value;  
        Approval(msg.sender, _spender, _value);  
        return true;  
    }  
        
    {% if (o.includeApproveAndCall) { %}    
    /**  
    * Approve and then communicate the approved contract in a single transaction  
    */  
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {  
        TokenRecipient spender = TokenRecipient(_spender);  
        if (approve(_spender, _value)) {  
            spender.receiveApproval(msg.sender, _value, this, _extraData);  
            return true;  
        }  
    }  
    {% } %}

    {% if (o.includeTransferAndCall) { %}    
    /**  
    * Transfer and then communicate the contract in a single transaction  
    */  
    function transferAndCall(address _recipient, uint256 _value, bytes _extraData) public returns (bool success) {  
        TokenRecipient recipient = TokenRecipient(_recipient);  
        if (transfer(_recipient, _value)) {  
            recipient.tokenFallback(msg.sender, _value, _extraData);  
            return true;  
        }  
    }  
    {% } %}
        
    /**  
    * Returns number of allowed tokens for given address.  
    */  
    function allowance(address _owner, address _spender) onlyPayloadSize(2) constant public returns (uint256 remaining) {  
        return allowed[_owner][_spender];  
    }  
        
    {% if (o.isMintable) { %} 
    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        uint256 newTotalSupply = totalSupply + _amount;
        {% if (o.isCapped) { %} 
        require(newTotalSupply <= capAmount);
        {% } %}
        totalSupply = newTotalSupply;
        balances[_to] = balances[_to] + _amount;
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
    * @dev Function to stop minting new tokens.
    * @return True if the operation was successful.
    */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
    {% } %}
    {% if (o.isCappingChangeable) { %} 
    /**
   	 * @dev Function to increase tokens cap limit
     * @param _amount The amount of tokens to increase cap
     * @return A boolean that indicates if the operation was successful.
     */
	function increaseCapAmount(uint256 _amount) onlyOwner public returns (bool) {
        capAmount = capAmount + _amount;
        CapAmountIncreased(_amount);
        return true;
    }

	/**
   	 * @dev Function to decrease tokens cap limit
     * @param _amount The amount of tokens to decrease cap
     * @return A boolean that indicates if the operation was successful.
     */
    function decreaseCapAmount(uint256 _amount) onlyOwner public returns (bool) {
        capAmount = capAmount - _amount;
        CapAmountDecreased(_amount);
        return true;
    }
    {% } %}
    {% if (o.isBurnable) { %} 
    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) {% if (!o.isBurnableByEveryone) { %}onlyOwner {% } %} public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner] - _value;
        totalSupply = totalSupply - _value;
        Burn(burner, _value);
    }
    {% } %}
    /**
     * Peterson's Law Protection
     * Claim tokens
     */
    function claimTokens(address _token) public ownerOnly {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            ClaimTransfer(owner, this.balance);
            return;
        }

        HVNToken token = HVNToken(this);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);

        ClaimTransfer(owner, balance);
    }
}  
