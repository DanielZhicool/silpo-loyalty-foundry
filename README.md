# Silpo Loyalty Smart Contract

## Опис проекту
Цей репозиторій містить смарт-контракт програми лояльності для мережі "Сільпо", розроблений на мові Solidity. 

Проект реалізує систему нарахування власних бонусних токенів "Власного Рахунку" (стандарт ERC-20) за покупки в магазині. Клієнти мають можливість накопичувати ці токени та обмінювати їх на знижки за допомогою механіки спалювання (burn mechanics). Для отримання знижки користувач повинен спалити рівно 100 токенів, що автоматично змінює його статус у системі.

## Технологічний стек
* Мова: Solidity ^0.8.20
* Стандарти: ERC-20, ERC20Burnable 
* Бібліотеки: OpenZeppelin Contracts v5.x 
* Середовище тестування: Foundry (Forge Standard Library) 

## Основний функціонал
1. **Токен системи**: Контракт випускає токени з назвою `Silpo Vlasnyi Rakhunok` та символом `SILPO`.
2. **Рольова модель (AccessControl)**: 
   * Замість єдиного власника (`Ownable`) використовується безпечніший модуль управління доступом `AccessControl`.
   * `DEFAULT_ADMIN_ROLE` має права видавати та забирати інші ролі в системі.
   * `MINTER_ROLE` надається авторизованим адресам (наприклад, касовим серверам), які мають ексклюзивне право карбувати (mint) токени для клієнтів.
3. **Активація знижки**: Функція `redeemDiscount()` перевіряє, чи має користувач 100 токенів і чи не була знижка активована раніше. У разі успіху токени знищуються (`_burn`), а статус `hasDiscount` стає `true`.

## Заходи безпеки (Security)
Контракт розроблено з урахуванням найкращих практик безпеки смарт-контрактів:
* **Захист від Reentrancy**: Логіка функції `redeemDiscount()` суворо дотримується патерну `Checks-Effects-Interactions`, змінюючи стан системи до виклику будь-яких зовнішніх/внутрішніх механізмів спалювання.
* **Перевірка вхідних даних (Input Validation)**: Використовуються оператори `require` для валідації балансу та запобігання подвійній активації знижки (Double Redeem).
* **Моніторинг (Off-chain Monitoring)**: Критичні зміни стану генерують події (наприклад, `DiscountRedeemed`), що дозволяє зовнішнім сервісам відстежувати активність у реальному часі.
* **Захист від переповнення**: Використання Solidity 0.8.20+ гарантує нативний захист від цілочисельного переповнення (Integer Overflow/Underflow).

## Тестування
Проект покритий автоматизованими тестами за допомогою фреймворку Foundry. Серед протестованих сценаріїв:
* Успішне карбування токенів авторизованим мінтером.
* Блокування доступу до карбування для адміністратора без ролі `MINTER_ROLE` та сторонніх користувачів (очікування кастомної помилки `AccessControlUnauthorizedAccount`).
* Коректне спалювання 100 токенів та надання знижки.
* Відхилення транзакцій при спробі отримати знижку з недостатнім балансом.
* Захист від повторного застосування знижки (реверт транзакції).

## Інструкція з локального запуску
Для компіляції та запуску тестів необхідно мати встановлений Foundry.

1. Клонуйте репозиторій:
   ```bash
   git clone <https://github.com/DanielZhicool/silpo-loyalty-foundry>
   cd silpo-loyalty-foundry

2.  Встановіть залежності OpenZeppelin:

    ```bash
    forge install openzeppelin/openzeppelin-contracts

3. Скомпілюйте проект:

    ```bash 
    forge build

4. Запустіть тестування:

    ```bash
    forge test -vv

# Silpo Loyalty Smart Contract

## Project Description
This repository contains the smart contract for the "Silpo" loyalty program, developed in Solidity. 

The project implements a system for issuing proprietary reward tokens "Vlasnyi Rakhunok" (ERC-20 standard) for store purchases. Customers can accumulate these tokens and exchange them for discounts using burn mechanics. To receive a discount, a user must burn exactly 100 tokens, which automatically changes their status in the system.

## Technology Stack
* Language: Solidity ^0.8.20
* Standards: ERC-20, ERC20Burnable.
* Libraries: OpenZeppelin Contracts v5.x .
* Testing Environment: Foundry (Forge Standard Library) .

## Core Functionality
1. **System Token**: The contract issues tokens named `Silpo Vlasnyi Rakhunok` with the symbol `SILPO`.
2. **Role-Based Access (AccessControl)**: 
   * Instead of a single owner (`Ownable`), the more secure `AccessControl` access management module is used.
   * `DEFAULT_ADMIN_ROLE` has the right to grant and revoke other roles in the system.
   * `MINTER_ROLE` is granted to authorized addresses (e.g., POS servers) that have the exclusive right to mint tokens for customers.
3. **Discount Activation**: The `redeemDiscount()` function checks if the user has at least 100 tokens and if the discount hasn't been activated before. Upon success, the tokens are destroyed (`_burn`), and the `hasDiscount` status becomes `true`.

## Security Measures
The contract is designed with smart contract security best practices in mind:
* **Reentrancy Protection**: The logic of the `redeemDiscount()` function strictly follows the `Checks-Effects-Interactions` pattern, changing the system state before calling any internal mechanisms for burning tokens.
* **Input Validation**: `require` statements are used to validate the user's balance and prevent double discount activation.
* **Off-chain Monitoring**: Critical state changes emit events (e.g., `DiscountRedeemed`), allowing external services to track activity in real-time.
* **Overflow Protection**: Using Solidity 0.8.20+ guarantees native protection against Integer Overflow/Underflow.

## Testing
The project is covered by automated tests using the Foundry framework. The tested scenarios include:
* Successful token minting by an authorized minter.
* Blocking mint access for an administrator without the `MINTER_ROLE` and external users (expecting the custom `AccessControlUnauthorizedAccount` error).
* Correct burning of 100 tokens and granting the discount.
* Reverting transactions when attempting to get a discount with an insufficient balance.
* Protection against double discount application (transaction revert).

## Local Setup Instructions
To compile and run the tests, you need to have Foundry installed.

1. Clone the repository:
   ```bash
   git clone https://github.com/username/silpo-loyalty.git
   
2. Install OpenZeppelin dependencies:

    ```bash
    forge install openzeppelin/openzeppelin-contracts

3. Compile the project:

    ```bash 
    forge build

4. Run tests:

    ```bash
    forge test -vv
