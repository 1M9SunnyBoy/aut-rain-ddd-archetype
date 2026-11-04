#set( $dollar = '$' )
#set( $hash = '#' )
${hash} 前端开发规范

版本：v1.0；更新：2026-11-02。适用于本脚手架生成的前端工程。

本文只约束通用工程实践。业务实体、状态流转、身份与授权规则由项目需求决定；路由和功能配置可采用代码或数据库方案，由项目架构明确。不强制实现动态运行目录，也不限制项目建设登录、人员或权限功能。

${hash}${hash} 1. 技术基线与当前范围

| 项目 | 约定 |
| --- | --- |
| 运行环境 | Node.js 22.22.0，开发与构建环境一致 |
| 包管理 | Corepack + pnpm 11.0.8，提交 pnpm-lock.yaml，CI 使用 frozen-lockfile |
| 语言与 UI | TypeScript 严格模式、React 19、Ant Design 6 |
| 工具 | Vite、ESLint、Prettier、Vitest、Testing Library |
| 按需使用 | 已声明 React Router、TanStack Query、Zod；新增功能时负责实际接入 |

具体版本以 package.json 和锁文件为准，升级需记录兼容性、验证和恢复方式。当前模板只有起始页，不代表已经实现统一请求、鉴权、动态菜单、Query Provider 或全局错误边界。

${hash}${hash} 2. 代码组织

新增功能按规模逐步组织，不为空目录和抽象而拆分代码：

```text
src/
  app/                  Provider、应用装配、全局错误边界
  layouts/              页面壳、导航、面包屑
  routes/               路由与页面加载
  features/<feature>/
    api/                请求与响应解析
    components/         功能内组件
    hooks/              数据与交互编排
    model/              类型、校验与转换
    pages/              页面
  shared/               通用组件、请求、配置与工具
  test/                 测试初始化与夹具
```

功能模块通过公开入口协作，不跨模块引用内部实现。共享目录只收纳有明确复用场景的代码，避免万能 utils。组件名使用 PascalCase，Hook 使用 useXxx，事件处理器使用 handleXxx，布尔量使用 is/has/can/should 前缀。

${hash}${hash} 3. 类型和数据边界

- 保持 strict，禁止新增无理由的 any；外部输入先以 unknown 接收，再用校验器解析。
- 禁止使用 @ts-ignore。必要的 @ts-expect-error 必须说明原因、跟踪项和移除条件。
- API DTO、领域模型、表单草稿和展示模型按职责区分，不把数据库行结构直接用作组件契约。
- 对外业务 ID 使用字符串，避免 Java BIGINT 超出 JavaScript 安全整数范围；金额与高精度值使用约定的十进制字符串，不用浮点运算保证财务精度。
- 时间点采用含时区的 ISO 8601 字符串；业务日期采用 YYYY-MM-DD，不通过 UTC 转换造成日期偏移。
- 明确 null、字段缺失、空字符串的不同语义；请求字段命名、分页结构与后端契约保持一致。
- 公开函数声明清晰的输入输出类型；类型断言不能代替运行期校验。

建议在新项目评估启用 noUncheckedIndexedAccess、exactOptionalPropertyTypes、noImplicitOverride、noFallthroughCasesInSwitch 和 useUnknownInCatchVariables，并修复引入的错误。模板当前明确启用 strict，本文不声称上述选项均已逐项配置。

${hash}${hash} 4. React 与状态管理

组件负责展示和交互，领域规则、转换和请求编排使用独立函数或 Hook。遵守 Hooks 规则；useEffect 用于同步外部系统，不用于反复复制可推导的数据。

引入 Query 后，服务端状态由 Query 管理，表单建立独立且有明确重置时机的草稿。Query key 包含业务范围与全部影响结果的参数，mutation 成功后精确更新或失效相关查询，失败时保留输入。

页面区分加载、空数据、成功、请求失败与无权限；配置驱动页面还需区分配置错误和停用。不得在真实接口失败后静默回填模拟数据。Mock 仅用于隔离测试或明确标识的开发环境。

列表使用稳定 ID 作为 key；页面卸载清理订阅、定时器、事件和无效请求。新增请求层需处理超时、取消和响应竞争，防止旧响应覆盖新数据。根据测量结果使用 memo、useMemo、useCallback，避免预防性堆积。

${hash}${hash} 5. 接口与错误处理

普通 JSON 接口使用后端约定的 code/message/data。成功业务码为字符串 "00000"；先处理 HTTP 失败，再判断业务码，不通过 message 文案判断流程。204、文件下载和流式响应按各自协议处理，不强制解析为统一 JSON。

统一请求层应处理请求基址、超时、取消、错误转换和可用的 traceId；模板当前响应没有 traceId 字段，接入链路追踪时需前后端一并实现。生产使用相对 API 路径或环境配置，禁止把本机地址、密钥或测试身份打入产物。

路由参数、分页、排序和筛选值在请求前校验并编码。不得从不可信输入拼接任意请求地址。新增登录后，统一处理 401/403；按钮隐藏不能代替后端授权与归属校验。写请求不得无条件自动重试，涉及幂等时需与后端约定请求标识和恢复行为。

如果项目选择数据库驱动路由，只允许元数据引用已编译的组件白名单，不执行配置中的代码、SQL 或任意组件路径；这属于可选架构约束。

${hash}${hash} 6. UI、可访问性和文件

- 表单统一使用 Form/Form.Item，字段错误可定位；提交中防止重复操作，失败保留输入。
- 表格提供分页、加载、空状态和错误反馈；大数据集优先服务端分页、排序与筛选。
- 破坏性操作说明影响范围并要求确认；长流程选择 Drawer 或独立页面，避免嵌套弹窗。
- 颜色、间距、圆角、字体通过主题 Token 和公共样式管理，不在组件散落硬编码。
- 图标按钮提供可访问名称；状态同时提供文字，不能只依赖颜色。核心流程支持键盘、清晰焦点、弹窗退出和焦点恢复。
- 短反馈使用 message/notification，需要处理的错误使用字段提示、Alert 或 Result。按 WCAG 2.1 AA 目标检查关键交互，不把使用组件库视为自动达标。
- 附件上传显示进度、失败与重试；前端校验只作体验优化，实际类型、大小和访问控制由后端验证。
- 图片预览使用获授权的地址或 Blob URL，并在不再使用时释放 Blob URL。不直接渲染不可信 HTML/SVG，不把存储管理密钥交给浏览器。

${hash}${hash} 7. 质量与交付

新增功能覆盖类型边界、核心交互、错误/空状态和必要的请求行为。测试以用户可观察结果为主，不为低价值实现细节堆积断言。关键跨页面流程按需补 E2E；模板不宣称已经配置 E2E 或 CI。

在生成项目根目录逐条执行：

```powershell
corepack pnpm --dir web install --frozen-lockfile
corepack pnpm --dir web typecheck
corepack pnpm --dir web lint
corepack pnpm --dir web test
corepack pnpm --dir web format:check
corepack pnpm --dir web build
```

评审检查：接口契约、敏感数据、请求竞争、缓存更新、键盘操作及构建产物。source map 的发布策略由项目明确；日志不输出 Token、密码或完整敏感请求体。提交不包含 node_modules、dist、日志、密钥及本地环境文件。约定式提交示例：feat(web): add search filter。

文档中的规则需要通过配置、测试和人工评审落实，列出命令不等于已经存在自动 CI 门禁。启动前端、后端或数据库需获得明确授权，构建检查不等于启动授权。

注释统一遵循[注释规范](../注释/README.md)：覆盖接口契约、核心逻辑、对象属性及文件头。文件格式及第三方署名例外见该规范。

相关规范：[后端](../后端/README.md)、[数据库](../数据库/README.md)。
