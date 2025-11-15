# My First NFT - Aptos Move NFT 智能合约示例

这是一个基于 Aptos 区块链的 NFT（非同质化代币）智能合约示例项目，演示了如何在 Aptos 上创建 NFT 集合、铸造 NFT 和管理 NFT。

## 项目功能

这个项目实现了一个完整的 NFT 系统，包含以下功能：

1. **NFT 集合创建**：在模块初始化时自动创建一个名为 "mfers" 的无限集合
2. **NFT 铸造**：通过 `mint()` 函数铸造新的 NFT，每个 NFT 都有唯一的编号和 URI
3. **NFT 销毁**：通过 `burn()` 函数销毁 NFT（仅所有者可操作）
4. **事件记录**：铸造和销毁操作都会触发相应的事件，记录操作历史
5. **集合查询**：提供查询集合创建者地址和集合对象的函数

## 代码结构

- **模块名**：`my_first_nft::my_first_nft`
- **主要结构体**：
  - `SignerCapabilityStore` - 存储签名者能力，用于后续操作
  - `CollectionRefsStore` - 存储集合引用，用于管理集合
  - `TokenRefsStore` - 存储代币引用，用于管理代币（修改、销毁、转移等）
- **主要函数**：
  - `init_module()` - 模块初始化函数，创建 NFT 集合和必要的存储结构
  - `mint()` - 铸造新的 NFT（entry 函数）
  - `burn()` - 销毁指定的 NFT（entry 函数）
  - `get_collection_creator_address()` - 获取集合创建者地址（view 函数）
  - `get_collection_object()` - 获取集合对象（view 函数）
- **事件**：
  - `MintEvent` - 记录 NFT 铸造事件
  - `BurnEvent` - 记录 NFT 销毁事件

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

首先，需要设置 `my_first_nft` 的地址。查看你的账户地址：

```bash
aptos config show-profiles
```

然后使用命令行参数发布合约：

```bash
aptos move publish --named-addresses my_first_nft=<你的账户地址>
```

发布成功后，`init_module()` 函数会自动执行，创建一个名为 "mfers" 的 NFT 集合。

### 4. 查询集合信息

发布后，可以使用 view 函数查询集合创建者地址：

```bash
aptos move view --function-id <你的账户地址>::my_first_nft::get_collection_creator_address
```

查询集合对象：

```bash
aptos move view --function-id <你的账户地址>::my_first_nft::get_collection_object
```

### 5. 铸造 NFT

使用 `mint()` 函数铸造一个新的 NFT：

```bash
aptos move run --function-id <你的账户地址>::my_first_nft::mint
```

每次调用 `mint()` 都会创建一个新的 NFT，NFT 会自动编号（如 "mfer #1", "mfer #2" 等），并设置对应的 URI。

### 6. 销毁 NFT

使用 `burn()` 函数销毁指定的 NFT（只有 NFT 的所有者才能销毁）：

```bash
aptos move run --function-id <你的账户地址>::my_first_nft::burn --args address:<NFT对象地址>
```

> **注意**：NFT 对象地址是 NFT 被铸造时分配的唯一地址，可以通过查看 `MintEvent` 事件获取。

### 7. 查看 NFT 信息

你可以在 Aptos Explorer（探索器）中查看你的 NFT：

1. 访问 [Aptos Testnet Explorer](https://explorer.aptoslabs.com/?network=testnet)
2. 在搜索框中输入你的账户地址
3. 在账户详情页面中，你可以查看该账户拥有的所有 NFT 对象
4. 点击具体的 NFT 对象可以查看详细信息，包括名称、URI、元数据等

## 项目文件

- `sources/my_first_nft.move` - Move 智能合约源代码
- `Move.toml` - Move 项目配置文件
- `.gitignore` - Git 忽略文件配置

## 依赖

- **AptosFramework** - Aptos 核心框架，提供对象系统、事件系统等基础功能
- **AptosStdlib** - Aptos 标准库，提供字符串工具等实用功能
- **AptosTokenObjects** - Aptos Token 对象库，提供 NFT 集合和代币功能

## 测试

运行测试：

```bash
aptos move test
```

## NFT 集合信息

本合约创建的 NFT 集合具有以下特征：

- **集合名称**：mfers
- **集合描述**：mfers are generated entirely from hand drawings by sartoshi. this project is in the public domain; feel free to use mfers any way you want.
- **集合类型**：无限集合（unlimited collection），不限制 NFT 数量
- **版税**：5%（支付给合约部署者）
- **代币命名**：自动编号，格式为 "mfer #1", "mfer #2" 等
- **代币 URI**：基于 IPFS，格式为 `ipfs://bafybeiearr64ic2e7z5ypgdpu2waasqdrslhzjjm65hrsui2scqanau3ya/<编号>.png`

## 注意事项

- 确保已安装 Aptos CLI 工具
- 首次发布需要足够的测试币支付 gas 费用
- 模块地址需要在发布前正确设置
- 每次铸造 NFT 都需要支付 gas 费用
- 只有 NFT 的所有者才能销毁该 NFT
- 销毁 NFT 是不可逆操作，请谨慎操作

