/// 我的第一个 NFT 模块
/// 这是一个基于 Aptos 区块链的 NFT 合约，用于创建和管理 NFT 集合和代币
module my_first_nft::my_first_nft {
    // 标准库导入
    use std::option;          // 选项类型，用于处理可选值
    use std::signer;          // 签名者类型，用于账户操作
    use std::string;          // 字符串类型
    use aptos_std::string_utils;  // 字符串工具函数
    use aptos_framework::event;   // 事件系统
    use aptos_framework::object;  // 对象系统
    use aptos_framework::object::Object;  // 对象类型

    // NFT 相关模块导入
    use aptos_token_objects::collection;  // 集合（Collection）功能
    use aptos_token_objects::royalty;     // 版税功能
    use aptos_token_objects::token;       // 代币（Token）功能
    use aptos_token_objects::token::Token; // 代币类型

    // ========== 常量定义 ==========
    
    /// 资源账户种子，用于创建资源账户
    const ResourceAccountSeed: vector<u8> = b"mfers";

    /// 集合描述信息
    const CollectionDescription: vector<u8> = b"mfers are generated entirely from hand drawings by sartoshi. this project is in the public domain; feel free to use mfers any way you want.";

    /// 集合名称
    const CollectionName: vector<u8> = b"mfers";

    /// 集合的 URI（统一资源标识符），指向集合的元数据
    const CollectionURI: vector<u8> = b"ipfs://QmWmgfYhDWjzVheQyV2TnpVXYnKR25oLWCB2i9JeBxsJbz";

    /// 代币的基础 URI，用于构建每个 NFT 的完整 URI
    const TokenURI: vector<u8> = b"ipfs://bafybeiearr64ic2e7z5ypgdpu2waasqdrslhzjjm65hrsui2scqanau3ya/";

    /// 代币名称前缀，例如 "mfer #1", "mfer #2" 等
    const TokenPrefix: vector<u8> = b"mfer #";

    // ========== 错误码定义 ==========
    
    /// 错误码：调用者不是 NFT 的所有者
    const ERROR_NOWNER: u64 = 1;

    // ========== 结构体定义 ==========
    
    /// 签名者能力存储结构体
    /// 用于存储集合创建者的扩展引用，允许后续扩展集合功能
    struct SignerCapabilityStore has key {
        extend_ref: object::ExtendRef  // 扩展引用，用于生成签名者以扩展对象
    }

    /// 集合引用存储结构体
    /// 存储集合对象和可变引用，用于后续对集合进行操作
    struct CollectionRefsStore has key {
        collection_object: Object<collection::Collection>,  // 集合对象
        mutator_ref: collection::MutatorRef                 // 集合可变引用，用于修改集合属性
    }

    /// 代币引用存储结构体
    /// 存储代币的各种引用，用于后续对代币进行操作（修改、销毁、转移等）
    struct TokenRefsStore has key {
        mutator_ref: token::MutatorRef,                    // 代币可变引用，用于修改代币属性
        burn_ref: token::BurnRef,                          // 销毁引用，用于销毁代币
        extend_ref: object::ExtendRef,                     // 扩展引用，用于扩展代币功能
        transfer_ref: option::Option<object::TransferRef>  // 转移引用（可选），用于转移代币所有权
    }

    // ========== 事件定义 ==========
    
    /// 铸造事件
    /// 当新的 NFT 被铸造时触发，记录所有者和代币 ID
    #[event]
    struct MintEvent has drop, store {
        owner: address,    // NFT 所有者的地址
        token_id: address  // 被铸造的 NFT 的 ID（对象地址）
    }

    /// 销毁事件
    /// 当 NFT 被销毁时触发，记录所有者和代币 ID
    #[event]
    struct BurnEvent has drop, store {
        owner: address,    // NFT 所有者的地址
        token_id: address  // 被销毁的 NFT 的 ID（对象地址）
    }

    /// 模块初始化函数
    /// 在模块部署时自动调用，用于创建 NFT 集合和必要的存储结构
    /// 
    /// 参数:
    /// - sender: 部署模块的账户签名者
    fun init_module(sender: &signer) {
        // 创建一个命名对象作为集合创建者，用于管理集合
        let collection_creator_cref = object::create_named_object(sender, b"");
        
        // 生成集合创建者的扩展引用，用于后续生成签名者
        let collection_creator_extend_ref =
            object::generate_extend_ref(&collection_creator_cref);
        
        // 从集合创建者对象生成签名者，用于执行需要签名的操作
        let collection_creator_signer =
            &object::generate_signer(&collection_creator_cref);

        // 创建无限集合（unlimited collection），即不限制代币数量的集合
        // 参数说明：
        // - collection_creator_signer: 集合创建者签名者
        // - CollectionDescription: 集合描述
        // - CollectionName: 集合名称
        // - 版税设置: 5/100 = 5% 的版税，支付给 sender 地址
        // - CollectionURI: 集合的元数据 URI
        let collection_cref =
            collection::create_unlimited_collection(
                collection_creator_signer,
                string::utf8(CollectionDescription),
                string::utf8(CollectionName),
                option::some(royalty::create(5, 100, signer::address_of(sender))),
                string::utf8(CollectionURI)
            );

        // 从集合对象生成签名者
        let collection_signer = &object::generate_signer(&collection_cref);

        // 生成集合的可变引用，用于后续修改集合属性
        let collection_mutator_ref = collection::generate_mutator_ref(&collection_cref);

        // 将集合引用存储到集合对象的存储中
        // TODO: 将集合引用存储到集合对象的存储中
        // abort 0;

        // 将签名者能力存储到集合创建者对象的存储中
        // 这样后续可以通过 extend_ref 生成签名者来执行操作
        move_to(
            collection_creator_signer,
            SignerCapabilityStore { extend_ref: collection_creator_extend_ref }
        );
    }

    /// 铸造 NFT 函数
    /// 创建一个新的 NFT 并将其转移给调用者
    /// 
    /// 参数:
    /// - sender: 调用此函数的账户签名者，将成为新铸造 NFT 的所有者
    entry public fun mint(sender: &signer) {
        // 从存储中获取集合创建者的扩展引用，并生成签名者
        // 这个签名者用于代表集合创建者执行操作（如创建代币）
        let collection_creator_signer =
            &object::generate_signer_for_extending(
                &SignerCapabilityStore[get_collection_creator_address()].extend_ref
            );
        
        // 初始化代币 URI 为基础 URI
        let url = string::utf8(TokenURI);

        // 创建编号代币（numbered token）
        // 参数说明：
        // - collection_creator_signer: 集合创建者签名者
        // - CollectionName: 集合名称
        // - CollectionDescription: 集合描述
        // - TokenPrefix: 代币名称前缀（如 "mfer #"）
        // - 空字符串: 代币名称后缀（这里为空）
        // - option::none(): 代币属性（这里不设置）
        // - 空字符串: 初始 URI（稍后会设置）
        let nft_cref =
            &token::create_numbered_token(
                collection_creator_signer,
                string::utf8(CollectionName),
                string::utf8(CollectionDescription),
                string::utf8(TokenPrefix),
                string::utf8(b""),
                option::none(),
                string::utf8(b"")
            );

        // 获取代币的索引号（编号），用于构建唯一的 URI
        let id = token::index<Token>(object::object_from_constructor_ref(nft_cref));
        
        // 将索引号追加到 URI 中
        url.append(string_utils::to_string(&id));
        
        // 追加文件扩展名 ".png"
        url.append(string::utf8(b".png"));

        // 从代币对象生成签名者
        let nft_signer = &object::generate_signer(nft_cref);

        // 生成代币的可变引用，用于修改代币属性（如设置 URI）
        let token_mutator_ref = token::generate_mutator_ref(nft_cref);

        // 设置代币的完整 URI（包含索引号和文件扩展名）
        token::set_uri(&token_mutator_ref, url);

        // 将代币从集合创建者转移给调用者（sender）
        // 这样调用者就成为新铸造 NFT 的所有者
        object::transfer(
            collection_creator_signer,
            object::object_from_constructor_ref<token::Token>(nft_cref),
            signer::address_of(sender)
        );

        // 将代币的各种引用存储到代币对象的存储中
        // 这些引用用于后续对代币进行操作（修改、销毁、转移等）
        move_to(
            nft_signer,
            TokenRefsStore {
                mutator_ref: token::generate_mutator_ref(nft_cref),      // 可变引用
                burn_ref: token::generate_burn_ref(nft_cref),            // 销毁引用
                extend_ref: object::generate_extend_ref(nft_cref),       // 扩展引用
                transfer_ref: option::some(object::generate_transfer_ref(nft_cref))  // 转移引用
            }
        );

        // 触发铸造事件，记录铸造信息
        // 这允许链下应用监听和响应 NFT 铸造事件
        event::emit(
            MintEvent {
                owner: signer::address_of(sender),                        // 新所有者地址
                token_id: object::address_from_constructor_ref(nft_cref)  // 代币 ID（对象地址）
            }
        );

    }

    /// 销毁 NFT 函数
    /// 销毁指定的 NFT，只有 NFT 的所有者才能销毁
    /// 
    /// 参数:
    /// - sender: 调用此函数的账户签名者
    /// - object: 要销毁的 NFT 对象
    entry fun burn(sender: &signer, object: Object<token::Token>) {
        // 验证调用者是否为 NFT 的所有者
        // 如果不是所有者，则抛出错误 ERROR_NOWNER
        assert!(object::is_owner(object, signer::address_of(sender)), ERROR_NOWNER);
        
        // 从代币对象的存储中提取 TokenRefsStore
        // 使用解构赋值获取 burn_ref，其他引用使用 _ 忽略
        let TokenRefsStore { mutator_ref: _, burn_ref, extend_ref: _, transfer_ref: _ } =
            move_from<TokenRefsStore>(object::object_address(&object));

        // 触发销毁事件，记录销毁信息
        // 在销毁前触发，以便记录原始所有者信息

        // TODO: 触发销毁事件，记录销毁信息
        abort 0;
        // 触发销毁事件，记录销毁信息（记录原始所有者和 token id）
        // event::emit(
        //     BurnEvent {
        //         owner: signer::address_of(sender),
        //         token_id: object::address_from_object(&object)
        //     }
        // );
        

        // 使用销毁引用来销毁代币
        // 这会永久删除代币，无法恢复
        token::burn(burn_ref);
    }

    /// 获取集合创建者地址
    /// 返回集合创建者对象的地址
    /// 
    /// 返回:
    /// - address: 集合创建者对象的地址
    #[view] // 添加 view 注解，表示这是一个只读函数 （4. 查询集合信息
    public fun get_collection_creator_address(): address {
        // 根据合约地址和空种子创建对象地址
        // 这与 init_module 中创建命名对象时使用的参数一致
        object::create_object_address(&@my_first_nft, b"")
    }

    /// 获取集合对象
    /// 返回集合的 Object 引用，用于查询集合信息
    /// 
    /// 返回:
    /// - Object<collection::Collection>: 集合对象
    #[view]
    public fun get_collection_object(): Object<collection::Collection> {
        // 根据集合创建者地址和集合名称创建集合地址
        // 然后将地址转换为对象引用
        object::address_to_object(
            collection::create_collection_address(
                &get_collection_creator_address(),
                &string::utf8(CollectionName)
            )
        )
    }

    /// 测试专用初始化函数
    /// 仅在测试环境中使用，用于初始化模块
    /// 
    /// 参数:
    /// - sender: 测试账户签名者
    #[test_only]
    public fun init_for_test(sender: &signer) {
        init_module(sender)
    }
}
