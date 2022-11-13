/*检验重复值*/
select customer_id,goods_id,category,behavior,tsp
from userbehavior 
group by customer_id,goods_id,category,behavior,tsp
having count(*) > 1;

/*缺失值处理*/
select count(customer_id),count(goods_id),count(category),count(behavior),count(tsp)
from userbehavior; 

/*关闭safe-mode以执行修改命令*/
set SQL_SAFE_UPDATES = 0;  

/*增加一列用于将原数据中的时间格式转化为可读的格式*/
alter table userbehavior add column tsp1 timestamp(0);
update userbehavior
set tsp1 = from_unixtime(tsp) ;

/*将原数据中的日期和时间分开*/
alter table userbehavior add dates varchar(255);
update userbehavior 
set dates = from_unixtime(tsp,'%Y-%m-%d');
alter table userbehavior add times varchar(255);
update userbehavior
set times = from_unixtime(tsp,'%H:%i:%s');

/*异常值处理，查找并删除不在要求期间内的数据
select tsp1
from userbehavior
where tsp1 < '2017-11-25 00:00:00' or tsp1 > '2017-12-04 00:00:00';*/

delete from userbehavior
where tsp1 < '2017-11-25 00:00:00' or tsp1 > '2017-12-04 00:00:00';

/*检验剩下数据是否有异常*/
select min(tsp1),max(tsp1)
from userbehavior;

/*数据集整体概况*/
select
	count(customer_id) as 数据总数,
	count(distinct customer_id) as 用户数,
	count(distinct goods_id) as 商品数量,
	count(distinct category) as 商品类型数量,
    sum(if (behavior='pv',1,0)) as 点击次数,
    sum(if (behavior='fav',1,0)) as 收藏次数,
	sum(if (behavior='cart',1,0)) as 加购次数,
	sum(if (behavior='buy',1,0)) as 购买次数
from userbehavior;

/*人均页面访问量PV/UV*/
select 
	count(distinct customer_id) as 'UV',
    (select count(customer_id) from userbehavior where behavior='pv') as 'PV',
    (select PV) / count(distinct customer_id) as 'PV/UV'
from userbehavior;

/*跳出率=仅点击页面用户数/总用户数UV*/
select count(distinct customer_id)/(select count(distinct customer_id) from userbehavior) as 'bounce_rate'
from userbehavior
where customer_id not in (select customer_id from userbehavior where behavior = 'buy') and 
    customer_id not in (select customer_id from userbehavior where behavior = 'cart') and
    customer_id not in (select customer_id from userbehavior where behavior = 'fav');

/*人均成交量*/
select count(customer_id)/(select count(distinct customer_id) from userbehavior) as 人均成交量
from userbehavior
where behavior = 'buy';


/*用户行为整体分析*/
select behavior,count(*) as behavior_sum
from userbehavior
group by behavior
order by behavior_sum desc;

/*独立访客行为统计*/
select behavior,count(distinct customer_id) as behavior_sum
from userbehavior
group by behavior
order by behavior_sum desc;


/*每日用户访客量、点击量、成交量*/
select 
	dates as 日期,
    count(distinct customer_id) as 日访客量,
    sum(if(behavior='pv',1,0)) as 日点击量,
    sum(if(behavior='buy',1,0)) as 日成交量
from userbehavior
group by dates
order by dates;

/*各时段用户点击量统计*/
select
	sum(if (times between '00:00:00' and '00:59:59',1,0)) as '0~1',
    sum(if (times between '01:00:00' and '01:59:59',1,0)) as '1~2',
	sum(if (times between '02:00:00' and '02:59:59',1,0)) as '2~3',
    sum(if (times between '03:00:00' and '03:59:59',1,0)) as '3~4',
    sum(if (times between '04:00:00' and '04:59:59',1,0)) as '4~5',
    sum(if (times between '05:00:00' and '05:59:59',1,0)) as '5~6',
    sum(if (times between '06:00:00' and '06:59:59',1,0)) as '6~7',
    sum(if (times between '07:00:00' and '07:59:59',1,0)) as '7~8',
    sum(if (times between '08:00:00' and '08:59:59',1,0)) as '8~9',
    sum(if (times between '09:00:00' and '09:59:59',1,0)) as '9~10',
    sum(if (times between '10:00:00' and '10:59:59',1,0)) as '10~11',
    sum(if (times between '11:00:00' and '11:59:59',1,0)) as '11~12',
    sum(if (times between '12:00:00' and '12:59:59',1,0)) as '12~13',
    sum(if (times between '13:00:00' and '13:59:59',1,0)) as '13~14',
    sum(if (times between '14:00:00' and '14:59:59',1,0)) as '14~15',
    sum(if (times between '15:00:00' and '15:59:59',1,0)) as '15~16',
    sum(if (times between '16:00:00' and '16:59:59',1,0)) as '16~17',
    sum(if (times between '17:00:00' and '17:59:59',1,0)) as '17~18',
    sum(if (times between '18:00:00' and '18:59:59',1,0)) as '18~19',
    sum(if (times between '19:00:00' and '19:59:59',1,0)) as '19~20',
    sum(if (times between '20:00:00' and '20:59:59',1,0)) as '20~21',
    sum(if (times between '21:00:00' and '21:59:59',1,0)) as '21~22',
    sum(if (times between '22:00:00' and '22:59:59',1,0)) as '22~23',
    sum(if (times between '23:00:00' and '23:59:59',1,0)) as '23~24'
from userbehavior
where behavior = 'pv';

/*各时段用户购买量统计*/
select
	sum(if (times between '00:00:00' and '00:59:59',1,0)) as '0~1',
    sum(if (times between '01:00:00' and '01:59:59',1,0)) as '1~2',
	sum(if (times between '02:00:00' and '02:59:59',1,0)) as '2~3',
    sum(if (times between '03:00:00' and '03:59:59',1,0)) as '3~4',
    sum(if (times between '04:00:00' and '04:59:59',1,0)) as '4~5',
    sum(if (times between '05:00:00' and '05:59:59',1,0)) as '5~6',
    sum(if (times between '06:00:00' and '06:59:59',1,0)) as '6~7',
    sum(if (times between '07:00:00' and '07:59:59',1,0)) as '7~8',
    sum(if (times between '08:00:00' and '08:59:59',1,0)) as '8~9',
    sum(if (times between '09:00:00' and '09:59:59',1,0)) as '9~10',
    sum(if (times between '10:00:00' and '10:59:59',1,0)) as '10~11',
    sum(if (times between '11:00:00' and '11:59:59',1,0)) as '11~12',
    sum(if (times between '12:00:00' and '12:59:59',1,0)) as '12~13',
    sum(if (times between '13:00:00' and '13:59:59',1,0)) as '13~14',
    sum(if (times between '14:00:00' and '14:59:59',1,0)) as '14~15',
    sum(if (times between '15:00:00' and '15:59:59',1,0)) as '15~16',
    sum(if (times between '16:00:00' and '16:59:59',1,0)) as '16~17',
    sum(if (times between '17:00:00' and '17:59:59',1,0)) as '17~18',
    sum(if (times between '18:00:00' and '18:59:59',1,0)) as '18~19',
    sum(if (times between '19:00:00' and '19:59:59',1,0)) as '19~20',
    sum(if (times between '20:00:00' and '20:59:59',1,0)) as '20~21',
    sum(if (times between '21:00:00' and '21:59:59',1,0)) as '21~22',
    sum(if (times between '22:00:00' and '22:59:59',1,0)) as '22~23',
    sum(if (times between '23:00:00' and '23:59:59',1,0)) as '23~24'
from userbehavior
where behavior = 'buy';

/*商品复购次数*/
create view goodsbuytimes as
select goods_id,count(customer_id) as buytimes
from userbehavior
where behavior = 'buy'
group by goods_id;

select buytimes as 复购次数,count(goods_id) as 商品数量
from goodsbuytimes
group by buytimes
order by buytimes;

/*复购次数超过五次的商品*/
select goods_id as 商品,buytimes as 复购次数
from goodsbuytimes
where buytimes>=5
order by buytimes desc;

/*不同商品类型购买情况*/
create view categorybuytimes as
select category,count(customer_id) as buytimes
from userbehavior
where behavior = 'buy'
group by category;

select buytimes as 复购次数,count(category) as 商品类目数量
from categorybuytimes
group by buytimes
order by buytimes;

/*复购次数超过60次的商品*/
select category as 商品类目,buytimes as 复购次数
from categorybuytimes
where buytimes>=60
order by buytimes desc;

/*点击Top20商品*/
select goods_id,count(*) as sum
from userbehavior
where behavior = 'pv'
group by goods_id
order by sum desc
limit 20;

/*加购Top20商品*/
select goods_id,count(*) as sum
from userbehavior
where behavior = 'cart'
group by goods_id
order by sum desc
limit 20;

/*收藏Top20商品*/
select goods_id,count(*) as sum
from userbehavior
where behavior = 'fav'
group by goods_id
order by sum desc
limit 20;

/*购买Top20商品*/
select goods_id,count(*) as sum
from userbehavior
where behavior = 'buy'
group by goods_id
order by sum desc
limit 20;

/*最后一次消费时间和消费频率*/
create view rfm as
select 
	customer_id,
    timestampdiff(hour,max(tsp1),'2017-12-04') as 最后一次购买时间,
    count(customer_id) 购买频率
from userbehavior
group by customer_id
order by 最后一次购买时间 desc;

/*计算R值中位数*/
select avg(最后一次购买时间) as R值中位数
from(
	select 
		最后一次购买时间,
        row_number() over (order by 最后一次购买时间) as rn,
        count(*) over() as n
    from rfm
) as r
where rn in (floor(n/2)+1,if(mod(n,2) = 0,floor(n/2),floor(n/2)+1));

/*计算F值中位数*/
select avg(购买频率) as F值中位数
from(
	select 
		购买频率,
        row_number() over (order by 购买频率) as rn,
        count(*) over() as n
    from rfm
) as f
where rn in (floor(n/2)+1,if(mod(n,2) = 0,floor(n/2),floor(n/2)+1));

/*用中位数界定高低维度并对用户分类*/
create view customertags as 
select 
	customer_id,
    (case when 最后一次购买时间<4 and 购买频率>75 then '重要价值客户'
    when 最后一次购买时间>=4 and 购买频率>75 then '重要保持客户'
    when 最后一次购买时间<4 and 购买频率<=75 then '一般发展客户'
    when 最后一次购买时间>=4 and 购买频率<=75 then '一般挽留客户'
    else null end) 用户标签
from rfm;

/*统计各类用户人数*/
select 用户标签,count(customer_id) as 人数
from customertags
group by 用户标签;

/*最受重要价值客户欢迎的商品*/
select goods_id,count(customer_id) as buytimes
from(
	select customer_id,goods_id
	from userbehavior
	where behavior = 'buy' and customer_id in (
		select customer_id 
		from customertags 
		where 用户标签='重要价值客户')
) as 重要价值客户购买商品
group by goods_id
order by buytimes desc;

/*最受重要价值客户欢迎的商品类型*/
select category,count(customer_id) as buytimes
from(
	select customer_id,category
	from userbehavior
	where behavior = 'buy' and customer_id in (
		select customer_id 
		from customertags 
		where 用户标签='重要价值客户')
) as 重要价值客户购买商品类型
group by category
order by buytimes desc;