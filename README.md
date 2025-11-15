# Hello Blockchain - Aptos Move 智能合约示例

这是一个简单的 Aptos Move 智能合约示例项目，演示了如何在 Aptos 区块链上存储和修改消息。

## 项目功能

这个项目实现了一个简单的消息存储系统，包含以下功能：

1. **消息存储**：使用 `MessageHolder` 资源在链上存储一条消息
2. **读取消息**：通过 `get_message()` 函数查询当前存储的消息
3. **修改消息**：通过 `set_message()` 函数更新消息内容
4. **事件记录**：每次消息变更都会触发 `MessageChange` 事件，记录变更历史

## 代码结构

- **模块名**：`hello_blockchain::message`
- **资源**：`MessageHolder` - 存储消息的链上资源
- **函数**：
  - `init_module()` - 初始化模块，设置默认消息为 "Hello, Blockchain"
  - `get_message()` - 查询当前消息（view 函数）
  - `set_message()` - 修改消息（entry 函数）
- **事件**：`MessageChange` - 记录消息变更事件

## 使用步骤

### 1. 初始化 Aptos 账户（Testnet）

```bash
aptos init --network testnet
```

```shell
$ aptos init --network testnet

Configuring for profile default
Configuring for network Testnet
Enter your private key as a hex literal (0x...) [Current: None | No input: Generate new key (or keep one if present)]

（此处需要 回车 继续创建一个私钥）

No key given, generating key...

---
Aptos CLI is now set up for account 0xac3b25cf6ba24f259ee2c8289c39e25efc02408d562b475d716f8f6f6f43e247 as profile default!
---

The account has not been funded on chain yet. To fund the account and get APT on testnet you must visit https://aptos.dev/network/faucet?address=0xac3b25cf6ba24f259ee2c8289c39e25efc02408d562b475d716f8f6f6f43e247
Press [Enter] to go there now > 

（此处如果回车则直接进入水龙头网址前往领水，与下方 步骤 2 相同）

```

当前命令中的输出结果中的 `0xac3b25cf6ba24f259ee2c8289c39e25efc02408d562b475d716f8f6f6f43e247` 是你的地址（可以认为是在 Blockchain 中的账号


```
---
Aptos CLI is now set up for account 0xac3b25cf6ba24f259ee2c8289c39e25efc02408d562b475d716f8f6f6f43e247 as profile default!
---
```

当你需要别人给你转账的时候，请给他这个地址（但请注意要保护好自己的私钥）

私钥默认的创建位置是当前目录的 .aptos 目录下的 config.yaml 文件中 (请勿给他人展示此文件内容)

```
---
profiles:
  default:
    network: Testnet
    private_key: ed25519-priv-0x04405809141c20fea82c71816db99a666a74273d977f1e88386a4c2199764096
    public_key: ed25519-pub-0x469c20cca1ee6a727ed6c84ab2523e98966b3f440b157433fc1b30605110361e
    account: ac3b25cf6ba24f259ee2c8289c39e25efc02408d562b475d716f8f6f6f43e247
    rest_url: "https://fullnode.testnet.aptoslabs.com"
```



### 2. 获取测试币

可以通过 `aptos account balance` 命令查看当前地址的余额 

有两种方式可以获取测试币：

**方式一：通过 Aptos 测试网水龙头（推荐）**

1. 访问 [Aptos 测试网水龙头](https://aptos.dev/zh/network/faucet)
2. 使用你的 **Google 账户登录**（防止滥用）
3. 输入你的 Aptos 测试网钱包地址（可以通过 `aptos config show-profiles` 查看）
4. 点击 **请求 APT** 即可立即收到测试币
5. 检查你的钱包余额，代币应在几秒钟内到账

**方式二：请求他人转账**

如果无法使用水龙头，可以请求其他拥有测试币的账户向你转账一些测试币。

> **提示：** 测试币仅用于测试目的，没有任何现实世界价值，且不能兑换成主网 APT。

### 3. 设置模块地址并发布合约

首先，需要设置 `hello_blockchain` 的地址。查看你的账户地址：

```bash
aptos config show-profiles
```

然后更新 `Move.toml` 文件中的地址，或者使用命令行参数：

```bash
aptos move publish --named-addresses hello_blockchain=<你的账户地址>
```

### 4. 查询消息

发布后，可以使用 view 函数查询当前消息：

```bash
aptos move view --function-id <你的账户地址>::message::get_message
```

### 5. 修改消息

使用 `set_message` 函数修改消息：

```bash
aptos move run --function-id <你的账户地址>::message::set_message --args string:"Hello, Aptos!"
```

### 6. 验证修改

再次查询消息，确认修改成功：

```bash
aptos move view --function-id <你的账户地址>::message::get_message
```

## 项目文件

- `sources/helloworld.move` - Move 智能合约源代码
- `Move.toml` - Move 项目配置文件
- `.gitignore` - Git 忽略文件配置

## 依赖

- Aptos Framework

## 测试

运行测试：

```bash
aptos move test
```

## 注意事项

- 确保已安装 Aptos CLI 工具
- 首次发布需要足够的测试币支付 gas 费用
- 模块地址需要在发布前正确设置

