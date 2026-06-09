PRAGMA foreign_keys = ON;

.headers on
.mode column

.print '============================================================'
.print '1. 조인 1개를 두 방식으로 풀기'
.print '============================================================'

.print ''
.print 'query 1. JOIN 방식'
.print 'description: 주문 이력이 있는 고객 조회'
SELECT DISTINCT
    c.id AS customer_id,
    c.name AS customer_name,
    c.phone,
    c.email
FROM customer c
INNER JOIN orders o
ON c.id = o.customer_id
ORDER BY c.id;

.print ''
.print 'query 2. 서브 쿼리 방식'
.print 'description: 주문 이력이 있는 고객 id 목록을 먼저 구한 뒤, 해당 고객만 조회'
SELECT 
    c.id AS customer_id,
    c.name AS customer_name,
    c.phone,
    c.email
FROM customer c
WHERE c.id IN (
    SELECT o.customer_id
    FROM orders o
)
ORDER BY c.id;

.print ''
.print 'description: JOIN과 서브쿼리 방식의 차이점'
.print 'JOIN 방식은 customer와 orders를 직접 연결하므로 두 테이블의 컬럼을 함께 조회하기 좋다.'
.print '예를 들어 고객명과 주문일, 주문상태를 한 번에 보고 싶을 때 적합하다.'
.print '서브쿼리 방식은 특정 조건을 만족하는 대상만 필터링할 때 읽기 쉽다.'
.print '현재 요구사항처럼 고객 정보만 필요하면 서브쿼리 방식도 충분히 명확하다.'
.print '하지만 주문 정보까지 함께 출력해야 한다면 JOIN 방식이 더 적합하다.'


.print ''
.print '============================================================'
.print '2. 데이터 정합성 깨뜨려 보기'
.print '============================================================'

.print ''
.print 'query 1. FK 에러가 나는 쿼리'
.print 'description: order_item.menu_id는 menu.id를 참조한다.'
.print 'description: 현재 menu 테이블에 id=999인 메뉴가 없으므로 FOREIGN KEY constraint failed 에러가 발생한다.'
INSERT INTO order_item (
    id,
    order_id,
    menu_id,
    quantity,
    unit_price
) VALUES (
    100, 
    1,
    999,
    1,
    5000
);

.print ''
.print 'query 2. 고치는 방법 1 - 존재하는 menu_id 사용'
.print 'description: 이미 존재하는 menu_id=20을 사용하여 order_item 데이터를 입력'
INSERT INTO order_item (
    id,
    order_id,
    menu_id,
    quantity,
    unit_price
) VALUES (
    100, 
    1,
    20,
    1,
    5000
);

.print ''
.print 'query 3. order_item 입력 결과 확인'
.print 'description: id=100인 주문 상세 데이터가 입력되었는지 확인'
SELECT *
FROM order_item
WHERE id = 100;

.print ''
.print 'query 4. 테스트용 order_item 데이터 삭제'
.print 'description: 다음 테스트를 위해 id=100인 order_item 데이터를 삭제'
DELETE FROM order_item
WHERE id = 100;

.print ''
.print 'query 5. 삭제 결과 확인'
.print 'description: id=100인 order_item 데이터가 삭제되어 조회 결과가 없어야 한다'
SELECT *
FROM order_item
WHERE id = 100;

.print ''
.print 'query 6. 고치는 방법 2 - 부모 데이터 먼저 입력'
.print 'description: order_item이 참조할 수 있도록 menu 테이블에 id=999인 부모 데이터를 먼저 입력'
INSERT INTO menu (
    id,
    category_id,
    name,
    price,
    is_available
) VALUES (
    999,
    10,
    '테스트 음료',
    5000,
    1
);

.print ''
.print 'query 7. 부모 데이터 입력 결과 확인'
.print 'description: menu 테이블에 id=999인 테스트 메뉴가 입력되었는지 확인'
SELECT *
FROM menu
WHERE id = 999;

.print ''
.print 'query 8. 부모 데이터를 참조하는 자식 데이터 입력'
.print 'description: menu_id=999가 menu 테이블에 존재하므로 order_item 입력이 가능하다'
INSERT INTO order_item (
    id,
    order_id,
    menu_id,
    quantity,
    unit_price
) VALUES (
    100,
    1,
    999,
    1,
    5000
);

.print ''
.print 'query 9. order_item 입력 결과 확인'
.print 'description: id=100인 order_item 데이터가 menu_id=999를 참조하며 입력되었는지 확인'
SELECT *
FROM order_item
WHERE id = 100;

.print ''
.print 'query 10. 테스트용 order_item 데이터 삭제'
.print 'description: 테스트 후 자식 데이터인 order_item을 먼저 삭제'
DELETE FROM order_item
WHERE id = 100;

.print ''
.print 'query 11. 테스트용 menu 데이터 삭제'
.print 'description: 자식 데이터를 삭제한 뒤 부모 데이터인 menu를 삭제'
DELETE FROM menu
WHERE id = 999;

.print ''
.print 'query 12. 테스트 데이터 삭제 결과 확인'
.print 'description: id=100인 order_item과 id=999인 menu가 모두 삭제되어 조회 결과가 없어야 한다'
SELECT *
FROM order_item
WHERE id = 100;

SELECT *
FROM menu
WHERE id = 999;

.print ''
.print 'description: FK 제약조건 정리'
.print 'order_item.menu_id는 menu.id를 참조하는 FK이다.'
.print '존재하지 않는 menu_id=999를 order_item에 입력하려고 하면 참조 대상이 없기 때문에 입력이 막힌다.'
.print '이를 해결하려면 이미 존재하는 menu_id를 사용하거나, menu 테이블에 부모 데이터를 먼저 입력한 뒤 order_item에 자식 데이터를 입력해야 한다.'
.print 'FK 제약조건은 잘못된 참조 데이터가 저장되는 것을 막아 데이터 정합성을 보장한다.'


.print ''
.print '============================================================'
.print '3. 미니 리포트 만들기'
.print '============================================================'

.print ''
.print 'query 1. 완료 주문 기준 총 매출 조회'
.print 'description: 매출 관점에서 실제 완료된 주문에서 발생한 총 매출 조회'
SELECT SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o
INNER JOIN order_item oi 
ON o.id = oi.order_id
WHERE o.status = 'COMPLETED';

.print ''
.print 'query 2. 인기 메뉴 TOP 5 조회'
.print 'description: 상품 관점에서 어떤 메뉴가 가장 많이 팔렸는지 조회'
SELECT 
    m.id AS menu_id,
    m.name AS menu_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM orders o
INNER JOIN order_item oi
ON o.id = oi.order_id
INNER JOIN menu m
ON oi.menu_id = m.id
WHERE o.status = 'COMPLETED'
GROUP BY m.id, m.name
ORDER BY total_quantity_sold DESC, m.id ASC
LIMIT 5;

.print ''
.print 'query 3. 고객별 누적 주문 금액 조회'
.print 'description: 고객 관점에서 주요 고객과 구매 규모 조회'
SELECT 
    c.id AS customer_id,
    c.name AS customer_name,
    COUNT(DISTINCT o.id) AS completed_order_count,
    SUM(oi.quantity * oi.unit_price) AS total_order_amount
FROM customer c
INNER JOIN orders o
ON c.id = o.customer_id
INNER JOIN order_item oi
ON o.id = oi.order_id
WHERE o.status = 'COMPLETED'
GROUP BY c.id, c.name
ORDER BY total_order_amount DESC, c.id ASC;