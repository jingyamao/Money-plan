# Money Plan 理财管理软件开发计划

## 一、项目概述

**项目名称：** Money Plan
**目标平台：** Web、iOS、macOS
**核心理念：** 帮助用户建立理财意识，控制日常消费，实现财务目标

## 二、技术选型

### 前端框架：Flutter
**选择理由：**
- 一套代码适配 Web、iOS、macOS
- 优秀的性能和流畅的动画效果
- 丰富的 UI 组件库
- 接近原生的用户体验

### 后端服务：Supabase
**选择理由：**
- 开源 Firebase 替代方案
- 内置 PostgreSQL 数据库
- 实时数据同步
- 内置身份认证
- Edge Functions 支持自定义逻辑

### AI 大模型：Claude API
**选择理由：**
- 强大的分析能力
- 支持中文
- 可定制化提示词

## 三、功能模块设计

### 1. 核心记账模块

#### 1.1 手动记账
- 快速记账入口
- 分类选择（餐饮、交通、购物、娱乐等）
- 金额输入
- 备注和标签
- 日期时间选择

#### 1.2 自动记账（支付宝/微信）
**实现方案：**
- **方案A：通知监听（推荐）**
  - iOS：使用 Notification Service Extension
  - macOS：监听系统通知
  - 解析支付宝/微信支付通知
  - 自动提取金额和商户信息

- **方案B：账单导入**
  - 支持导出支付宝/微信账单 CSV
  - 一键导入并解析
  - 自动分类

#### 1.3 消费分类
- 餐饮美食
- 交通出行
- 购物消费
- 生活服务
- 娱乐休闲
- 医疗健康
- 教育学习
- 其他支出

### 2. 预算管理模块

#### 2.1 预算设置
- 月度生活费设置
- 分类预算设置
- 预算周期选择（周/月/年）

#### 2.2 预算监控
- 实时预算消耗进度
- 剩余可用金额计算
- 日均可用金额计算

#### 2.3 超支预警
- 预算消耗百分比提醒（50%、80%、100%）
- 超支后通知提醒
- 自定义预警阈值

### 3. AI 智能分析模块

#### 3.1 消费分析
- 消费趋势分析
- 消费结构分析
- 异常消费检测
- 消费建议生成

#### 3.2 智能提醒
- 每日消费报告
- 超标实时提醒
- 理财建议推送

#### 3.3 对话式查询
- "我这个月花了多少钱？"
- "我的钱都花在哪里了？"
- "按照目前的消费速度，月底能存多少？"

### 4. 存款目标模块

#### 4.1 目标设定
- 目标名称（如：买车、旅行、应急基金）
- 目标金额
- 目标日期
- 优先级设置

#### 4.2 进度追踪
- 当前存款进度
- 预计完成时间
- 每月需存金额计算

#### 4.3 智能规划
- 根据收入和支出计算可存金额
- 自动调整存款计划
- 多目标平衡建议

### 5. 数据统计模块

#### 5.1 收支统计
- 日/周/月/年收支趋势
- 收支分类饼图
- 同比环比分析

#### 5.2 资产总览
- 总资产统计
- 各账户余额
- 资产变化趋势

## 四、UI 设计规范

### 设计风格
- **设计语言：** Material Design 3 + 自定义设计系统
- **色彩方案：** 清新简约，主色调为蓝绿色系
- **字体：** 中文使用思源黑体，英文使用 Inter
- **图标：** 线性图标风格，简洁明了

### 核心页面设计

#### 1. 首页（Dashboard）
```
┌─────────────────────────────────┐
│  今日消费        本月剩余        │
│  ¥128.50        ¥2,871.50      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  预算进度 65%                   │
├─────────────────────────────────┤
│  快速记账    [+ 记一笔]         │
├─────────────────────────────────┤
│  最近交易                       │
│  ├── 午餐    ¥25.00   餐饮     │
│  ├── 地铁    ¥4.00    交通     │
│  └── 咖啡    ¥18.00   餐饮     │
├─────────────────────────────────┤
│  AI 洞察                       │
│  "今日消费低于日均，继续保持！"  │
└─────────────────────────────────┘
```

#### 2. 记账页面
- 大数字键盘
- 分类图标网格
- 智能识别（输入金额后自动推荐分类）

#### 3. 统计页面
- 可切换的时间周期
- 交互式图表
- 分类详情列表

#### 4. 目标页面
- 目标卡片式展示
- 进度环形图
- 存款时间线

## 五、数据库设计

### 核心表结构

```sql
-- 用户表
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  monthly_budget DECIMAL(10,2),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 交易记录表
CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  amount DECIMAL(10,2) NOT NULL,
  type TEXT CHECK (type IN ('income', 'expense')),
  category TEXT NOT NULL,
  description TEXT,
  merchant TEXT,
  transaction_date TIMESTAMP,
  source TEXT CHECK (source IN ('manual', 'alipay', 'wechat', 'import')),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 预算表
CREATE TABLE budgets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  category TEXT,
  amount DECIMAL(10,2),
  period TEXT CHECK (period IN ('weekly', 'monthly', 'yearly')),
  start_date DATE,
  end_date DATE
);

-- 存款目标表
CREATE TABLE savings_goals (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name TEXT NOT NULL,
  target_amount DECIMAL(10,2),
  current_amount DECIMAL(10,2) DEFAULT 0,
  target_date DATE,
  priority INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 账户表
CREATE TABLE accounts (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name TEXT NOT NULL,
  type TEXT CHECK (type IN ('savings', 'checking', 'investment', 'cash')),
  balance DECIMAL(10,2),
  icon TEXT
);
```

## 六、开发阶段规划

### 第一阶段：基础框架（2周）
- [x] 项目初始化
- [ ] Flutter 项目搭建
- [ ] 基础 UI 框架
- [ ] Supabase 集成
- [ ] 用户认证

### 第二阶段：核心功能（3周）
- [ ] 手动记账功能
- [ ] 消费分类管理
- [ ] 基础统计图表
- [ ] 预算设置

### 第三阶段：智能功能（2周）
- [ ] Claude API 集成
- [ ] AI 消费分析
- [ ] 智能提醒系统
- [ ] 对话式查询

### 第四阶段：高级功能（2周）
- [ ] 通知监听自动记账
- [ ] 账单导入功能
- [ ] 存款目标规划
- [ ] 多账户管理

### 第五阶段：优化完善（1周）
- [ ] UI 动画优化
- [ ] 性能优化
- [ ] 多平台适配测试
- [ ] Bug 修复

## 七、项目结构

```
money_plan/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── theme.dart
│   │   ├── routes.dart
│   │   └── constants.dart
│   ├── models/
│   │   ├── transaction.dart
│   │   ├── budget.dart
│   │   ├── savings_goal.dart
│   │   └── account.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── transaction_provider.dart
│   │   └── budget_provider.dart
│   ├── screens/
│   │   ├── home/
│   │   ├── transaction/
│   │   ├── statistics/
│   │   ├── goals/
│   │   └── settings/
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── ai_service.dart
│   │   └── notification_service.dart
│   ├── widgets/
│   │   ├── common/
│   │   ├── charts/
│   │   └── cards/
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
├── assets/
│   ├── icons/
│   ├── images/
│   └── fonts/
├── test/
├── web/
├── ios/
└── macos/
```

## 八、依赖包清单

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  fl_chart: ^0.66.0
  intl: ^0.19.0
  provider: ^6.1.1
  go_router: ^13.0.0
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^17.0.0
  http: ^1.2.0
  uuid: ^4.3.3
  table_calendar: ^3.0.9
  flutter_slidable: ^3.0.1
  animated_text_kit: ^4.2.2
  lottie: ^3.0.0
  google_fonts: ^6.1.0
```

## 九、AI 提示词设计

### 消费分析提示词
```
你是一个专业的理财顾问。根据用户的消费记录，分析消费习惯并提供建议。

用户消费数据：
{transaction_data}

请分析：
1. 消费结构是否合理
2. 是否存在异常消费
3. 本月预算执行情况
4. 具体的省钱建议

请用简洁友好的语气回复，适合手机通知展示。
```

### 对话查询提示词
```
你是一个智能理财助手，名叫"小财"。用户会用自然语言询问关于财务的问题。

用户数据上下文：
- 本月预算：{monthly_budget}
- 本月已消费：{monthly_spent}
- 今日消费：{today_spent}
- 账户余额：{balance}
- 存款目标：{savings_goals}

用户问题：{user_question}

请给出准确、有帮助的回答。如果涉及具体数字，请精确计算。
```

## 十、注意事项

### 安全性
- 所有敏感数据加密存储
- 使用 Supabase Row Level Security
- API 密钥安全存储

### 隐私保护
- 消费数据仅存储在用户账户
- AI 分析不存储个人敏感信息
- 提供数据导出和删除功能

### 性能优化
- 列表懒加载
- 图表数据缓存
- 减少不必要的网络请求

---

**预计总开发时间：** 10周
**MVP版本发布时间：** 第5周结束
