// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SilpoLoyalty
 * @dev Програма лояльності Сільпо (ERC-20 + Burn mechanics + AccessControl)
 */
contract SilpoLoyalty is ERC20, ERC20Burnable, AccessControl {
    // Унікальний ідентифікатор для ролі мінтера (bytes32)
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    // Вартість знижки: 100 токенів
    uint256 public constant DISCOUNT_COST = 100 * 10**18;
    
    // Відображення статусу покупця
    mapping(address => bool) public hasDiscount;

    // Подія для відстеження отриманих знижок off-chain
    event DiscountRedeemed(address indexed customer);

    /**
     * @dev Конструктор ініціалізує ім'я, символ токена та призначає початкові ролі.
     * @param defaultAdmin Адреса головного адміністратора (керує ролями).
     * @param minter Адреса, яка отримує право мінтити токени.
     */
    constructor(address defaultAdmin, address minter) 
        ERC20("Silpo Vlasnyi Rakhunok", "SILPO") 
    {
        // Призначаємо головну адміністративну роль (має право видавати/забирати інші ролі)
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        
        // Призначаємо роль мінтера для нарахування токенів за покупки
        _grantRole(MINTER_ROLE, minter);
    }

    /**
     * @dev Функція мінту токенів. 
     * Викликати може лише акаунт із роллю MINTER_ROLE завдяки модифікатору onlyRole.
     * @param to Адреса клієнта.
     * @param amount Кількість токенів (в wei).
     */
    function mintTokens(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @dev Спалює рівно 100 токенів для отримання знижки та змінює статус покупця.
     */
    function redeemDiscount() external {
        // 1. Checks: Перевірка балансу та статусу
        require(balanceOf(msg.sender) >= DISCOUNT_COST, "Silpo: Insufficient token balance");
        require(!hasDiscount[msg.sender], "Silpo: Discount already applied");

        // 2. Effects: Зміна стану до взаємодій
        hasDiscount[msg.sender] = true;

        // Виклик внутрішньої функції _burn для знищення токенів
        _burn(msg.sender, DISCOUNT_COST);

        // Емісія події для моніторингу
        emit DiscountRedeemed(msg.sender);
    }
}
