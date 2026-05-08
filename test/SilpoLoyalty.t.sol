// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {SilpoLoyalty} from "../src/SilpoLoyalty.sol";

contract SilpoLoyaltyTest is Test {
    SilpoLoyalty public silpo;

    // Створюємо тестові адреси (акаунти) за допомогою Foundry makeAddr
    address public admin = makeAddr("admin");
    address public minter = makeAddr("minter");
    address public customer = makeAddr("customer");
    address public unauthorized = makeAddr("unauthorized");

    // Хеш ролі для перевірки (має збігатися з контрактом)
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant DISCOUNT_COST = 100 * 10**18;

    // Функція setUp викликається перед кожним тестом
    function setUp() public {
        // Деплоїмо контракт, передаючи admin та minter
        silpo = new SilpoLoyalty(admin, minter);
    }

    /* -------------------------------------------------------------------------- */
    /*                                 Мінтер (Mint)                              */
    /* -------------------------------------------------------------------------- */

    function test_MintTokens_Success() public {
        uint256 amountToMint = 150 * 10**18;
        
        // vm.prank змінює msg.sender на minter для наступного виклику
        vm.prank(minter);
        silpo.mintTokens(customer, amountToMint);

        // Перевіряємо, чи баланс клієнта оновився правильно
        assertEq(silpo.balanceOf(customer), amountToMint);
    }

    function test_MintTokens_RevertIf_Unauthorized() public {
        uint256 amountToMint = 150 * 10**18;

        // В OpenZeppelin v5 AccessControl відхиляє транзакцію з цією кастомною помилкою
        bytes memory expectedError = abi.encodeWithSignature(
            "AccessControlUnauthorizedAccount(address,bytes32)", 
            unauthorized, 
            MINTER_ROLE
        );
        
        vm.expectRevert(expectedError);
        
        // Робимо виклик від акаунта, який не має MINTER_ROLE
        vm.prank(unauthorized);
        silpo.mintTokens(customer, amountToMint);
    }

    function test_MintTokens_RevertIf_AdminWithoutMinterRole() public {
        uint256 amountToMint = 100 * 10**18;

        // Формуємо очікувану помилку OpenZeppelin: AccessControlUnauthorizedAccount(address, bytes32)
        bytes memory expectedError = abi.encodeWithSignature(
            "AccessControlUnauthorizedAccount(address,bytes32)", 
            admin, // Перевіряємо, що помилка виникає саме для адреси admin
            MINTER_ROLE
        );
        
        // Вказуємо Foundry очікувати відкат наступної транзакції з цією помилкою
        vm.expectRevert(expectedError);
        
        // Робимо виклик від акаунта адміністратора, який має DEFAULT_ADMIN_ROLE, але НЕ має MINTER_ROLE
        vm.prank(admin);
        silpo.mintTokens(customer, amountToMint);
    }

    /* -------------------------------------------------------------------------- */
    /*                                Знижки (Redeem)                             */
    /* -------------------------------------------------------------------------- */

    function test_RedeemDiscount_Success() public {
        // Нараховуємо 100 токенів покупцю
        vm.prank(minter);
        silpo.mintTokens(customer, DISCOUNT_COST);

        // Покупець викликає обмін знижки
        vm.prank(customer);
        silpo.redeemDiscount();

        // Перевіряємо зміну стану
        assertEq(silpo.balanceOf(customer), 0); // Всі 100 токенів згоріли
        assertTrue(silpo.hasDiscount(customer)); // Знижка стала активною
    }

    function test_RedeemDiscount_RevertIf_InsufficientBalance() public {
        // Нараховуємо покупцю менше, ніж потрібно (99 токенів)
        uint256 lowBalance = 99 * 10**18;
        vm.prank(minter);
        silpo.mintTokens(customer, lowBalance);

        // Очікуємо конкретне повідомлення про помилку за допомогою expectRevert
        vm.expectRevert("Silpo: Insufficient token balance");
        
        vm.prank(customer);
        silpo.redeemDiscount();
    }

    function test_RedeemDiscount_RevertIf_AlreadyApplied() public {
        // Нараховуємо покупцю токенів з запасом на дві знижки (250 токенів)
        vm.prank(minter);
        silpo.mintTokens(customer, 250 * 10**18);

        // Перший успішний виклик
        vm.prank(customer);
        silpo.redeemDiscount();
        assertTrue(silpo.hasDiscount(customer));

        // Спроба отримати знижку вдруге
        vm.expectRevert("Silpo: Discount already applied");
        
        vm.prank(customer);
        silpo.redeemDiscount(); // Транзакція має впасти (revert)
    }
}