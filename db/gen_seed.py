# -*- coding: utf-8 -*-
"""生成 seed.sql：30个农园、200+商品、商家、管理员、订单/预约等演示数据。
用法: PYTHONUTF8=1 python gen_seed.py  （在同目录生成 seed.sql）
"""
import random
import datetime

random.seed(20260904)  # 固定随机种子，保证可重复

try:
    import bcrypt
    def bhash(pwd):
        return bcrypt.hashpw(pwd.encode(), bcrypt.gensalt(10)).decode()
except ImportError:
    # 占位：运行时若无 bcrypt，则后续由后端首次启动时重置密码
    def bhash(pwd):
        return 'BCRYPT_PLACEHOLDER'

TODAY = datetime.date(2026, 9, 4)

# ============ 基础数据 ============
DISTRICTS = ['蓟州区', '西青区', '静海区', '宁河区', '宝坻区', '武清区', '北辰区', '津南区', '滨海新区']

# 9 家已通过商家 + 1 家待审核
MERCHANTS = [
    ('merchant01', '蓟州盘山果业有限公司', '张建国', '13800000001', 1),
    ('merchant02', '西青沙窝萝卜种植合作社', '李秀兰', '13800000002', 1),
    ('merchant03', '汉沽茶淀葡萄合作社', '王振海', '13800000003', 1),
    ('merchant04', '静海金丝小枣家庭农场', '刘芳', '13800000004', 1),
    ('merchant05', '宁河七里海河蟹养殖基地', '赵德顺', '13800000005', 1),
    ('merchant06', '宝坻小站稻米业公司', '陈永贵', '13800000006', 1),
    ('merchant07', '武清有机蔬菜农场联盟', '孙丽梅', '13800000007', 1),
    ('merchant08', '北辰果蔬采摘园', '周天成', '13800000008', 1),
    ('merchant09', '津南绿色农庄', '吴桂芝', '13800000009', 1),
    ('merchant10', '滨海新区海产干货行', '郑海生', '13800000010', 0),  # 待审核
]

# 30 个农园：(商家序号, 名称, 类型, 区县, 地址, 人均, 评分)
FARMS = [
    (1, '盘山红富士苹果园', '果园', '蓟州区', '蓟州区官庄镇盘山景区东门北行2公里', 68, 4.8),
    (1, '盘山磨盘柿采摘园', '果园', '蓟州区', '蓟州区官庄镇玉石庄村盘山南麓', 45, 4.7),
    (1, '蓟州山里红山楂园', '果园', '蓟州区', '蓟州区下营镇黄崖关长城西侧1公里', 40, 4.5),
    (1, '燕山板栗生态园', '果园', '蓟州区', '蓟州区罗庄子镇洪水庄村北', 55, 4.6),
    (2, '沙窝萝卜直供菜园', '有机蔬菜农场', '西青区', '西青区辛口镇小沙窝村村南', 30, 4.9),
    (2, '西青早春甜瓜大棚', '果园', '西青区', '西青区辛口镇水高庄村农业示范园内', 50, 4.4),
    (3, '茶淀玫瑰香葡萄园', '果园', '滨海新区', '滨海新区汉沽茶淀镇崔兴沽村', 60, 4.8),
    (3, '汉沽草莓采摘基地', '果园', '滨海新区', '滨海新区汉沽大田镇小马杓沽村', 88, 4.6),
    (4, '静海金丝小枣园', '果园', '静海区', '静海区独流镇十一堡村东', 35, 4.5),
    (4, '静海冬枣采摘园', '果园', '静海区', '静海区良王庄乡王家院村', 48, 4.4),
    (5, '七里海河蟹垂钓农庄', '有机蔬菜农场', '宁河区', '宁河区七里海镇俵口村湿地旁', 120, 4.7),
    (6, '宝坻小站稻体验农场', '有机蔬菜农场', '宝坻区', '宝坻区八门城镇欢喜庄村', 40, 4.6),
    (6, '宝坻天鹰椒种植园', '有机蔬菜农场', '宝坻区', '宝坻区林亭口镇糙甸村', 28, 4.3),
    (7, '武清有机番茄农场', '有机蔬菜农场', '武清区', '武清区河西务镇三街村', 35, 4.6),
    (7, '武清奶油草莓园', '果园', '武清区', '武清区大碱厂镇南辛庄村', 85, 4.7),
    (7, '武清鲜食玉米基地', '有机蔬菜农场', '武清区', '武清区泗村店镇窑上村', 25, 4.2),
    (8, '北辰红颜草莓采摘园', '果园', '北辰区', '北辰区双街镇庞咀村农业园', 90, 4.6),
    (8, '北辰樱桃采摘园', '果园', '北辰区', '北辰区西堤头镇东赵庄村', 128, 4.8),
    (9, '津南葡萄主题农庄', '果园', '津南区', '津南区八里台镇大孙庄村', 62, 4.5),
    (9, '津南无花果家庭农场', '果园', '津南区', '津南区小站镇东西庄房村', 70, 4.4),
    (1, '蓟州雪花梨采摘园', '果园', '蓟州区', '蓟州区马伸桥镇于各庄村', 42, 4.5),
    (1, '蓟州京白桃生态园', '果园', '蓟州区', '蓟州区穿芳峪镇新水厂村', 55, 4.6),
    (2, '西青盆栽蔬菜体验棚', '有机蔬菜农场', '西青区', '西青区杨柳青镇大柳滩村', 38, 4.3),
    (5, '宁河有机水稻农场', '有机蔬菜农场', '宁河区', '宁河区廉庄镇菜园村', 45, 4.5),
    (7, '武清西兰花出口基地', '有机蔬菜农场', '武清区', '武清区河北屯镇甄马营村', 22, 4.1),
    (3, '汉沽桃李杏三果园', '果园', '滨海新区', '滨海新区汉沽杨家泊镇付庄村', 50, 4.3),
    (4, '静海多肉植物园', '有机蔬菜农场', '静海区', '静海区双塘镇杨家园村', 30, 4.2),
    (6, '宝坻大蒜种植体验园', '有机蔬菜农场', '宝坻区', '宝坻区大口屯镇西刘举人庄村', 26, 4.0),
    (9, '津南小站稻垦殖园', '有机蔬菜农场', '津南区', '津南区小站镇会馆村小站稻核心区', 50, 4.7),
    (8, '北辰蓝莓主题农场', '果园', '北辰区', '北辰区青光镇刘家码头村', 98, 4.5),
]

# 商品名称模板：每类（品名, 分类, 商家序号, 价格区间, 产地, 规格列表）
PRODUCT_TMPL = [
    ('小站稻香米 {spec}', '粮油米面', 6, (39, 129), '天津宝坻', ['5斤装', '10斤装', '20斤装']),
    ('沙窝萝卜 {spec}', '时令蔬菜', 2, (12, 48), '天津西青', ['3斤装', '5斤装', '10斤装']),
    ('茶淀玫瑰香葡萄 {spec}', '时令水果', 3, (25, 88), '天津汉沽', ['2斤装', '4斤装', '6斤装']),
    ('盘山磨盘柿 {spec}', '时令水果', 1, (18, 60), '天津蓟州', ['3斤装', '5斤装']),
    ('七里海河蟹 {spec}', '禽蛋水产', 5, (88, 358), '天津宁河', ['公蟹4只装', '母蟹4只装', '公母混装8只']),
    ('静海金丝小枣 {spec}', '干货特产', 4, (15, 65), '天津静海', ['1斤装', '2斤装', '5斤装']),
    ('燕山板栗 {spec}', '干货特产', 1, (22, 75), '天津蓟州', ['2斤装', '4斤装']),
    ('宝坻天鹰椒 {spec}', '调味干货', 6, (10, 36), '天津宝坻', ['1斤装', '2斤装']),
    ('武清奶油草莓 {spec}', '时令水果', 7, (35, 99), '天津武清', ['2盒装', '4盒装']),
    ('有机番茄 {spec}', '时令蔬菜', 7, (15, 45), '天津武清', ['3斤装', '5斤装']),
    ('北辰红颜草莓 {spec}', '时令水果', 8, (48, 128), '天津北辰', ['3盒装', '6盒装']),
    ('津南无花果 {spec}', '时令水果', 9, (28, 78), '天津津南', ['2斤装', '4斤装']),
    ('宝坻大蒜 {spec}', '调味干货', 6, (8, 28), '天津宝坻', ['3头装', '10头装']),
    ('武清鲜食玉米 {spec}', '时令蔬菜', 7, (20, 55), '天津武清', ['8根装', '16根装']),
    ('蓟州山里红山楂 {spec}', '时令水果', 1, (12, 40), '天津蓟州', ['2斤装', '5斤装']),
    ('静海冬枣 {spec}', '时令水果', 4, (16, 56), '天津静海', ['2斤装', '4斤装']),
    ('武清西兰花 {spec}', '时令蔬菜', 7, (9, 25), '天津武清', ['2颗装', '4颗装']),
    ('汉沽桃子 {spec}', '时令水果', 3, (20, 60), '天津汉沽', ['3斤装', '6斤装']),
    ('小站稻蟹田米 {spec}', '粮油米面', 5, (45, 139), '天津宁河', ['5斤装', '10斤装']),
    ('蓟州京白桃 {spec}', '时令水果', 1, (22, 68), '天津蓟州', ['3斤装', '5斤装']),
    ('滨海新区虾干 {spec}', '干货特产', 9, (30, 95), '天津滨海', ['半斤装', '1斤装']),
    ('盆栽有机蔬菜 {spec}', '时令蔬菜', 2, (18, 58), '天津西青', ['单盆', '三盆组合']),
]

CATEGORIES = [
    ('时令水果', 0, 1), ('时令蔬菜', 0, 2), ('粮油米面', 0, 3),
    ('禽蛋水产', 0, 4), ('干货特产', 0, 5), ('调味干货', 0, 6),
    ('苹果', 1, 1), ('葡萄', 1, 2), ('草莓', 1, 3), ('枣类', 1, 4),
    ('蟹类', 4, 1), ('稻米', 3, 1), ('薯芋', 2, 1),
]

TRAFFIC_GUIDES = [
    '自驾：津蓟高速盘山出口下，沿盘山大道行驶2公里即到；公交：旅游专线11路盘山站下车步行800米。',
    '自驾：荣乌高速天津出口下，导航"小沙窝村"即可；公交：公交669路辛口站换乘便民3号线。',
    '自驾：长深高速汉沽出口下，沿汉北路行驶5公里；公交：公交455路茶淀镇站下车。',
    '自驾：京沪高速静海出口下，沿静文公路行驶8公里；公交：公交552路独流站下车步行1公里。',
    '自驾：滨保高速七里海出口下，沿七里海大道行驶3公里；公交：公交571路俵口站下车。',
]

INTROS = [
    '{name}坐落于天津{district}，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。',
    '{name}位于{district}核心农业示范区，是当地知名的家庭农场。所有作物按有机标准管理，农事体验丰富：游客可下田采摘、认养菜地、喂养小动物。园区提供免费停车位与采摘工具，雨天备有雨靴雨衣。',
    '{name}地处{district}生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。',
]

BANNERS = [
    ('金秋采摘季·蓟州苹果红了', 'product', 0, 1),
    ('茶淀玫瑰香葡萄限时特惠', 'product', 0, 2),
    ('沙窝萝卜·非遗美味直达', 'farm', 5, 3),
    ('小站稻蟹田米新米上市', 'product', 0, 4),
]

NOTICES = [
    ('平台试运营公告', '天津地方农特产推广服务平台于2026年9月正式上线试运营。平台首批入驻本地优质农户与农园30余家，覆盖蓟州、西青、静海、宁河等涉农区县。试运营期间全场满88元包邮，欢迎体验！', 3),
    ('金秋采摘季活动通知', '9月至11月为天津地区苹果、柿子、冬枣最佳采摘期。平台农园体验模块已上线"金秋采摘季"专题，预约任意农园即可获赠农家自种蔬菜一份（到园领取）。', 10),
    ('国庆假期预约提示', '国庆假期（10月1日至7日）为采摘高峰期，各农园场次库存有限，建议提前3天以上预约。到园后请向商家出示预留手机号以便现场确认。', 20),
]

def q(s):
    if s is None:
        return 'NULL'
    return "'" + str(s).replace("\\", "\\\\").replace("'", "\\'") + "'"

L = []
L.append('-- =====================================================================')
L.append('-- 天津地方农特产推广服务平台 演示数据')
L.append('-- 固定随机种子 20260904，可重复生成')
L.append('-- =====================================================================')
L.append('USE agri_platform;')
L.append('')

# ============ 管理员 ============
L.append('-- 平台管理员（admin/123456）')
L.append("INSERT INTO sys_admin (username, password_hash, name, role, status) VALUES")
L.append("('admin', {}, '超级管理员', 'SUPER', 1);".format(q(bhash('123456'))))
L.append('')

# ============ 商家 ============
L.append('-- 商家账号（密码均为 merchant123；merchant10 为待审核状态）')
L.append('INSERT INTO merchant (username, password_hash, name, license_info, contact, phone, intro, status) VALUES')
rows = []
for u, name, contact, phone, status in MERCHANTS:
    rows.append('({}, {}, {}, {}, {}, {}, {}, {})'.format(
        q(u), q(bhash('merchant123')), q(name),
        q('统一社会信用代码：91120{}{}{}{}MA{}{}{}{}X{}'.format(*random.sample('1234567890', 9))),
        q(contact), q(phone),
        q('{}_{}优质农副产品直供商家'.format(name[:4], '本地')),
        status))
L.append(',\n'.join(rows) + ';')
L.append('')

# ============ 用户 ============
L.append('-- 演示用户（openidx 为模拟微信openid）')
L.append('INSERT INTO user (openid, nickname, avatar, phone, status) VALUES')
L.append("('mock_openid_demo001', '津门吃货小王', '', '13911110001', 1),")
L.append("('mock_openid_demo002', '爱采摘的丽丽', '', '13911110002', 1),")
L.append("('mock_openid_demo003', '老天津卫张大爷', '', '13911110003', 1),")
L.append("('mock_openid_demo004', '亲子游达人', '', '13911110004', 1),")
L.append("('mock_openid_demo005', '健康饮食派', '', '13911110005', 1);")
L.append('')

# ============ 分类 ============
L.append('-- 商品分类')
L.append('INSERT INTO category (id, name, parent_id, sort, status) VALUES')
# 先插一级分类取 id，再插二级；这里手工固定 id
cat_id = 1
cat_rows = []
id_map = {}
for name, parent, sort in CATEGORIES:
    id_map[name] = cat_id
    cat_rows.append('({}, {}, {}, {}, 1)'.format(cat_id, q(name), parent if isinstance(parent, int) else id_map.get(parent, 0), sort * 10))
    cat_id += 1
L.append(',\n'.join(cat_rows) + ';')
L.append('')

# ============ 农园 ============
L.append('-- 农园（30个，覆盖天津各涉农区县）')
L.append('INSERT INTO farm (merchant_id, name, type, district, address, business_hours, intro, cover_image, avg_price, rating, traffic_guide, status) VALUES')
frows = []
for i, (mi, name, ftype, dist, addr, price, rating) in enumerate(FARMS):
    hours = random.choice(['08:30-17:00', '09:00-17:30', '08:00-16:30'])
    intro = random.choice(INTROS).format(name=name, district=dist)
    cover = '/api/file/placeholder/farm{}.png'.format(i + 1)
    guide = random.choice(TRAFFIC_GUIDES)
    frows.append('({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, 1)'.format(
        mi, q(name), q(ftype), q(dist), q(addr), q(hours), q(intro), q(cover),
        price, rating, q(guide)))
L.append(',\n'.join(frows) + ';')
L.append('')

# ============ 采摘项目 ============
L.append('-- 采摘项目（每农园1-3个）')
L.append('INSERT INTO picking_project (farm_id, name, season_start, season_end, price_mode, price, session, stock, status) VALUES')
prows = []
PROJECT_NAMES = {
    '果园': ['红富士苹果采摘', '玫瑰香葡萄采摘', '奶油草莓采摘', '磨盘柿采摘', '金丝小枣采摘',
            '京白桃采摘', '雪花梨采摘', '山楂采摘', '板栗采摘', '冬枣采摘', '无花果采摘',
            '蓝莓采摘', '樱桃采摘', '甜瓜采摘', '桃杏李混摘'],
    '有机蔬菜农场': ['有机番茄采摘', '沙窝萝卜拔取体验', '盆栽蔬菜认购', '西兰花采收体验',
                '鲜食玉米采摘', '水稻收割农事体验', '螃蟹垂钓体验', '大蒜采收体验', '多肉植物盆栽DIY'],
}
for i, (mi, name, ftype, dist, addr, price, rating) in enumerate(FARMS):
    farm_id = i + 1
    n = random.randint(1, 3)
    used = random.sample(PROJECT_NAMES[ftype], n)
    for pn in used:
        start = TODAY + datetime.timedelta(days=random.randint(-60, 60))
        end = start + datetime.timedelta(days=random.randint(90, 200))
        mode = random.choice(['按人头门票', '按采摘重量'])
        if mode == '按人头门票':
            pp = random.randrange(25, 130, 5)
        else:
            pp = random.randrange(8, 40, 2)
        stock = random.choice([20, 30, 40, 50, 60, 80])
        prows.append('({}, {}, {}, {}, {}, {}, {}, {}, 1)'.format(
            farm_id, q(pn), q(str(start)), q(str(end)), q(mode), pp,
            q('上午,下午'), stock))
L.append(',\n'.join(prows) + ';')
L.append('')

# ============ 商品（200+） ============
L.append('-- 商品（200+条，覆盖六大一级分类）')
L.append('INSERT INTO product (merchant_id, category_id, name, main_image, price, specs, stock, sales, origin, description, status) VALUES')
prows = []
count = 0
for base_name, cat, mi, (lo, hi), origin, specs in PRODUCT_TMPL:
    for grade in ['精选', '特选', '家庭装', '礼盒', '生态', '头茬', '新货', '直供', '老树', '当季']:
        for spec in specs:
            pname = base_name.format(spec=spec) + '（{}）'.format(grade)
            price = round(random.uniform(lo, hi), 1)
            # 一级分类优先
            cat_id = id_map.get(cat, 1)
            stock = random.choice([0, 15, 30, 50, 80, 100, 150, 200, 300, 500])
            sales = random.randint(0, 2000) if stock > 0 else random.randint(0, 30)
            desc = '{}，产自{}，{}。由{}直供发货，48小时内现摘现发，坏果包赔。'.format(
                pname, origin, random.choice(['当日现摘现发', '冷链直达', '产地直发', '坏果包赔']),
                MERCHANTS[mi - 1][1])
            prows.append('({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, 1)'.format(
                mi, cat_id, q(pname),
                q('/api/file/placeholder/p{}.png'.format(count + 1)),
                price, q(','.join(specs)), stock, sales, q(origin), q(desc)))
            count += 1
L.append(',\n'.join(prows) + ';')
L.append('-- 共 {} 个商品'.format(count))
L.append('')

# ============ 轮播图 / 公告 ============
L.append('-- 轮播图')
L.append('INSERT INTO banner (title, image, link_type, link_value, sort, status) VALUES')
brows = []
for i, (title, ltype, lval, sort) in enumerate(BANNERS):
    brows.append('({}, {}, {}, {}, {}, 1)'.format(
        q(title), q('/api/file/placeholder/banner{}.png'.format(i + 1)),
        q(ltype), lval if ltype != 'product' else '1', sort))
L.append(',\n'.join(brows) + ';')
L.append('')
L.append('-- 公告')
L.append('INSERT INTO notice (title, content, publish_time, status) VALUES')
nrows = []
for title, content, days_ago in NOTICES:
    t = datetime.datetime.combine(TODAY - datetime.timedelta(days=days_ago), datetime.time(10, 0))
    nrows.append('({}, {}, {}, 1)'.format(q(title), q(content), q(t.strftime('%Y-%m-%d %H:%M:%S'))))
L.append(',\n'.join(nrows) + ';')
L.append('')

# ============ 演示用户地址 ============
L.append('-- 演示用户的收货地址')
L.append('INSERT INTO address (user_id, receiver, phone, province, city, district, detail, is_default) VALUES')
L.append("(1, '王先生', '13911110001', '天津市', '天津市', '南开区', '长江道与红旗路交口融创中心3-1-502', 1),")
L.append("(2, '李女士', '13911110002', '天津市', '天津市', '河西区', '友谊南路与潭江道交口万科水晶城12-2-801', 1),")
L.append("(3, '张大爷', '13911110003', '天津市', '天津市', '河东区', '卫国道红星大厦B座1803', 1);")
L.append('')

# ============ 演示订单与预约 ============
L.append('-- 演示订单（覆盖各状态）')
L.append('INSERT INTO orders (order_no, user_id, total_amount, status, receiver, phone, address, remark, create_time, pay_time, ship_time, finish_time, cancel_time) VALUES')
orows = []
ADDRS = [('王先生', '13911110001', '天津市南开区长江道融创中心3-1-502'),
         ('李女士', '13911110002', '天津市河西区友谊南路万科水晶城12-2-801'),
         ('张大爷', '13911110003', '天津市河东区卫国道红星大厦B座1803'),
         ('亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902')]
now = datetime.datetime(2026, 9, 4, 15, 0, 0)
for i in range(30):
    uid = random.randint(1, 5)
    recv = ADDRS[min(uid - 1, 3)]
    status = random.choice([0, 1, 1, 2, 2, 3, 3, 3, 4, 3])
    amount = round(random.uniform(20, 400), 1)
    ct = now - datetime.timedelta(days=random.randint(0, 40), hours=random.randint(0, 20))
    pt = ct + datetime.timedelta(hours=1) if status >= 1 else None
    st = pt + datetime.timedelta(days=1) if status >= 2 else None
    ft = st + datetime.timedelta(days=3) if status == 3 else None
    cct = ct + datetime.timedelta(hours=2) if status == 4 else None
    orows.append('({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})'.format(
        q('SO2026{:06d}'.format(202609000000 + i * 37 % 999999 + i)),
        uid, amount, status, q(recv[0]), q(recv[1]), q(recv[2]), q(''),
        q(ct.strftime('%Y-%m-%d %H:%M:%S')),
        q(pt.strftime('%Y-%m-%d %H:%M:%S')) if pt else 'NULL',
        q(st.strftime('%Y-%m-%d %H:%M:%S')) if st else 'NULL',
        q(ft.strftime('%Y-%m-%d %H:%M:%S')) if ft else 'NULL',
        q(cct.strftime('%Y-%m-%d %H:%M:%S')) if cct else 'NULL'))
L.append(',\n'.join(orows) + ';')
L.append('')
L.append('-- 订单明细（每单1-3行，取商品id 1-210）')
L.append('INSERT INTO order_item (order_id, product_id, product_name, main_image, price, quantity, spec) VALUES')
irows = []
for oid in range(1, 31):
    for _ in range(random.randint(1, 3)):
        pid = random.randint(1, 210)
        irows.append('({}, {}, {}, {}, {}, 1, {})'.format(
            oid, pid, q('商品#{}演示快照'.format(pid)),
            q('/api/file/placeholder/p{}.png'.format(pid)),
            round(random.uniform(10, 200), 1), q('5斤装')))
L.append(',\n'.join(irows) + ';')
L.append('')

L.append('-- 演示预约单（覆盖各状态）')
L.append('INSERT INTO appointment (appointment_no, user_id, farm_id, project_id, appoint_date, session, people_count, amount, contact_name, contact_phone, status, merchant_read, create_time) VALUES')
arows = []
NAMES = ['王先生', '李女士', '张大爷', '刘女士', '陈先生']
for i in range(25):
    uid = random.randint(1, 5)
    farm_id = random.randint(1, 30)
    project_id = random.randint(1, 50)
    adate = TODAY + datetime.timedelta(days=random.randint(-30, 30))
    session = random.choice(['上午', '下午'])
    people = random.randint(1, 6)
    status = random.choice([0, 1, 1, 1, 2, 2, 3, 4])
    amount = round(random.uniform(30, 300), 1)
    ct = now - datetime.timedelta(days=random.randint(1, 30))
    arows.append('({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})'.format(
        q('AP2026{:06d}'.format(202609000000 + i * 53 % 999999 + i)),
        uid, farm_id, project_id, q(str(adate)), q(session), people, amount,
        q(NAMES[uid - 1]), q('1391111000{}'.format(uid)), status,
        random.randint(0, 1), q(ct.strftime('%Y-%m-%d %H:%M:%S'))))
L.append(',\n'.join(arows) + ';')
L.append('')

# ============ 演示评价 ============
L.append('-- 演示评价（商品/农园各若干）')
L.append('INSERT INTO review (rel_type, rel_id, user_id, rating, content, create_time) VALUES')
rrows = []
RCONTENTS = ['品质很好，很新鲜，家人都说不错，回购第二次了！',
             '包装用心，物流很快，产地直发果然不一样。',
             '口感纯正，就是有大小不太均匀，总体满意。',
             '孩子特别喜欢，下次还来！客服态度也很好。',
             '味道正宗，就是比菜市场稍微贵一点，胜在放心。',
             '采摘体验很棒，商家很热情，还会讲解种植知识。',
             '环境不错，采摘的果子很甜，性价比高。']
for i in range(20):
    rrows.append("('product', {}, {}, {}, {}, NOW() - INTERVAL {} DAY)".format(
        random.randint(1, 200), random.randint(1, 5), random.randint(3, 5),
        q(random.choice(RCONTENTS)), random.randint(1, 30)))
for i in range(15):
    rrows.append("('farm', {}, {}, {}, {}, NOW() - INTERVAL {} DAY)".format(
        random.randint(1, 30), random.randint(1, 5), random.randint(3, 5),
        q(random.choice(RCONTENTS[5:])), random.randint(1, 30)))
L.append(',\n'.join(rrows) + ';')
L.append('')

# ============ 意见反馈 ============
L.append('-- 意见反馈')
L.append('INSERT INTO feedback (user_id, content, contact, status, create_time) VALUES')
L.append("(1, '希望增加更多宝坻区的农园，想带孩子去体验水稻收割。', '13911110001', 0, NOW() - INTERVAL 2 DAY),")
L.append("(2, '建议预约时可以同时预约多个采摘项目。', '13911110002', 1, NOW() - INTERVAL 5 DAY),")
L.append("(4, '商品页面图片能再清晰一点就更好了。', '13911110004', 0, NOW() - INTERVAL 1 DAY);")
L.append('')

open(__file__.replace('gen_seed.py', 'seed.sql'), 'w', encoding='utf-8').write('\n'.join(L) + '\n')
print('seed.sql 生成完毕：商品 {} 条、农园 {} 个、预约 {} 单、订单 {} 单'.format(
    count, len(FARMS), len(arows), len(orows)))
