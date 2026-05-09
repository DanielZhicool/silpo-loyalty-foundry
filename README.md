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

### Prerequisites
- **Git** для клонування репозиторію
- **Foundry** (Forge, Cast, Anvil) для розробки та тестування
- **macOS/Linux/WSL2** для оптимальної сумісності

---

### Встановлення та запуск

 1. Встановіть Foundry (якщо ще не встановлено)

```bash
curl -L https://foundry.paradigm.xyz | bash
source $HOME/.bashrc  # або ~/.zshrc для macOS
foundryup
```

Перевіріть встановлення:
```bash
forge --version
```

 2. Клонуйте репозиторій

```bash
git clone https://github.com/DanielZhicool/silpo-loyalty-foundry.git
cd silpo-loyalty-foundry
```

 3. Встановіть залежності

Все необхідне вже встановлено, але при потребі переінсталяції:

```bash
forge install openzeppelin/openzeppelin-contracts
```

 4. Скомпілюйте проект

```bash
forge build
```

Очікуваний вихід:
```
Compiling 1 files with Solidity 0.8.20
Solc 0.8.20 finished in 2.50s
Compiler run successful!
```

 5. Запустіть тести

```bash
# Запуск усіх тестів з деталізацією
forge test -vv

# Запуск конкретного тесту
forge test --match testMintSuccess -vv

# Запуск з газовим звітом
forge test --gas-report
```

---

### Структура проекту

```
silpo-loyalty-foundry/
├── src/
│   └── SilpoLoyalty.sol          # Основний смарт-контракт
├── test/
│   └── SilpoLoyalty.t.sol        # Тести контракту
├── lib/
│   ├── forge-std/                # Стандартна бібліотека Foundry
│   └── openzeppelin-contracts/   # Контракти OpenZeppelin
├── foundry.toml                  # Конфігурація Foundry
├── remappings.txt                # Маршрутизація імпортів
└── README.md                     # Цей файл
```

---


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
### Prerequisites
- **Git** 
- **Foundry** (Forge, Cast, Anvil) for testing
- **macOS/Linux/WSL2** for best compatibility

---

### Installation and running tests

 1. Install foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
source $HOME/.bashrc  # or ~/.zshrc for macOS
foundryup
```

Check installation:
```bash
forge --version
```

 2. Clone repository

```bash
git clone https://github.com/DanielZhicool/silpo-loyalty-foundry.git
cd silpo-loyalty-foundry
```

 3. Install dependencies 

```bash
forge install openzeppelin/openzeppelin-contracts
```

 4. Compile project

```bash
forge build
```

Expected output:
```
Compiling 1 files with Solidity 0.8.20
Solc 0.8.20 finished in 2.50s
Compiler run successful!
```

 5. Run tests

```bash
# Run all tests
forge test -vv

# Run specific test
forge test --match testMintSuccess -vv

# Run with gas report
forge test --gas-report
```

---

### Project struture

```
silpo-loyalty-foundry/
├── src/
│   └── SilpoLoyalty.sol          # Main smart-contract
├── test/
│   └── SilpoLoyalty.t.sol        # Tests
├── lib/
│   ├── forge-std/                # standart Foundry library
│   └── openzeppelin-contracts/   # OpenZeppelin contracts
├── foundry.toml                  # Foundry configuration
├── remappings.txt                # import remapping
└── README.md                     # this file