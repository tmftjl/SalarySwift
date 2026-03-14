# SalarySwift

面向小型作坊场景的本地化工资记录 Android App。无需联网，所有数据存储在设备本地。

## 功能

### 工作台
- 按月录入每位员工的工资金额
- 左右切换月份，或点击年月弹窗选择任意年月
- 实时展示当月工资合计
- 有未保存修改时顶部提示，点击右上角"保存"写入数据库

### 员工库
- 新增、改名、软删除员工
- 软删除后不影响已录入的历史工资数据

### 历史工资
- 按月汇总展示所有已录入月份（总额 + 人数）
- 点击进入月份详情，查看每位员工当月工资

### 工资报表
- 新建结算批次（指定起止年月）
- 批次详情展示跨月员工×月份矩阵表格
- 支持导出 A4 竖向 PDF 并通过系统分享

## 技术栈

| 模块 | 依赖 |
|------|------|
| UI 框架 | Flutter + Material 3 |
| 状态管理 | flutter_riverpod（StateNotifier） |
| 本地数据库 | Drift + SQLite |
| PDF 生成 | pdf |
| 系统分享 | share_plus |
| 国际化工具 | intl |

## 数据模型

### employees
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 主键 |
| name | TEXT | 员工姓名 |
| is_active | INTEGER | 1=在职，0=软删除 |
| created_at | INTEGER | 创建时间戳 |

### salary_records
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 主键 |
| employee_id | INTEGER FK | 关联 employees.id |
| year | INTEGER | 工资所属年 |
| month | INTEGER | 工资所属月 |
| amount | INTEGER | 金额（以"分"为单位，避免浮点误差） |

唯一约束：`(employee_id, year, month)`

### batches
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 主键 |
| start_year / start_month | INTEGER | 批次起始年月 |
| end_year / end_month | INTEGER | 批次结束年月 |
| created_at | INTEGER | 创建时间戳 |

## 项目结构

```
lib/
├── main.dart
├── data/
│   ├── db/
│   │   ├── app_database.dart        # Drift 数据库入口
│   │   ├── database_provider.dart
│   │   ├── dao/
│   │   │   ├── employee_dao.dart
│   │   │   ├── salary_record_dao.dart
│   │   │   └── batch_dao.dart
│   │   └── entity/
│   │       ├── employee.dart
│   │       ├── salary_record.dart
│   │       └── batch.dart
│   └── repository/
│       ├── employee_repository.dart
│       ├── salary_repository.dart
│       └── batch_repository.dart
├── ui/
│   ├── main_screen.dart             # 底部导航
│   ├── workbench/
│   │   ├── workbench_screen.dart
│   │   └── workbench_viewmodel.dart
│   ├── employees/
│   │   ├── employees_screen.dart
│   │   └── employees_viewmodel.dart
│   ├── history/
│   │   ├── history_screen.dart
│   │   ├── history_detail_screen.dart
│   │   └── history_viewmodel.dart
│   └── salary_report/
│       ├── salary_report_screen.dart
│       ├── salary_report_detail_screen.dart
│       └── salary_report_viewmodel.dart
└── util/
    └── pdf_exporter.dart
```

## 开发

**首次运行前需生成 Drift 代码：**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**运行：**

```bash
flutter run
```

**字体：** PDF 导出使用 `assets/fonts/SimHei.ttf`，已随 App 打包，无需额外配置。

## 数据库版本

当前 schema version: **3**

| 版本 | 变更 |
|------|------|
| 1 | 初始结构 |
| 2 | salary_records 重建，新增 batches 表 |
| 3 | salary_records.amount 从浮点改为整型（分） |
