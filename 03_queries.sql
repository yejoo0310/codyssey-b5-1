PRAGMA foreign_keys = ON;

-- 1. 기본 조회

-- query 1. 전체 고객 조회
-- description: customer 테이블에 입력된 전체 고객 목록을 조회
SELECT id, name, phone, email, created_at
FROM customer;

-- query 2. 판매 가능한 메뉴 조회 (WHERE 사용)
-- description: is_available 값이 1인, 판매 가능 메뉴만 조회
SELECT id, name, price, is_available
FROM menu
WHERE is_available = 1;

-- query 3. 가격이 높은 메뉴 TOP 5 조회 (ORDER BY, LIMIT 사용)
-- description: 메뉴를 내림차순으로 정렬한 뒤 상위 5개 메뉴만 조회
SELECT id, name, price
FROM menu
ORDER BY price DESC, id ASC
LIMIT 5;

-- query 4. 라떼가 포함된 판매 가능 메뉴 조회 (WHERE, LIKE, ORDER BY 사용)
-- description: 메뉴 이름에 '라떼'가 포함된 판매 가능 메뉴를 내림차순으로 조회
SELECT id, name, price, is_available
FROM menu
WHERE name LIKE '%라떼%' AND is_available = 1
ORDER BY price DESC;


-- 2. JOIN

-- query 1. 주문과 고객 정보 조회 (INNER JOIN)
-- description: orders.customer_id와 customer.id를 연결해 주문한 고객 이름을 함께 조회
SELECT o.id AS order_id, c.id AS customer_id, c.name AS customer_name, o.ordered_at, o.status
FROM orders o
INNER JOIN customer c
ON o.customer_id = c.id
ORDER BY o.id ASC;

-- query 2. 메뉴와 카테고리 조회 (INNER JOIN)
-- description: menu.category_id와 category.id를 연결해 카테고리 이름을 함께 조회
SELECT m.id AS menu_id, m.name AS menu_name, c.name AS category_name, m.price, m.is_available
FROM menu m
INNER JOIN category c
ON m.category_id = c.id
ORDER BY c.id, m.id ASC;

-- query 3. 주문 상세 조회 (INNER JOIN)
-- description: order_item, orders, customer, menu를 연결해 주문별 고객명, 메뉴명, 수량, 금액을 조회
SELECT o.id AS order_id, c.name AS customer_name, m.name AS menu_name, oi.quantity, oi.quantity * oi.unit_price AS total_price, o.status, o.ordered_at
FROM order_item AS oi
INNER JOIN orders o
ON oi.order_id = o.id
INNER JOIN customer c
ON o.customer_id = c.id
INNER JOIN menu m
ON oi.menu_id = m.id
ORDER BY o.id, oi.id;

-- query 4. 고객별 주문 여부 조회 (LEFT JOIN)
-- description: 모든 고객을 기준으로 고객별 주문 목록을 조회
SELECT c.id AS customer_id, c.name AS customer_name, o.id AS order_id, o.status, o.ordered_at
FROM customer c
LEFT JOIN orders o
ON c.id = o.customer_id
ORDER BY c.id, o.id;

-- query 5. 카테고리별 메뉴 조회 (LEFT JOIN)
-- description: 모든 카테고리를 기준으로 연결된 메뉴를 조회
SELECT c.id AS category_id, c.name AS category_name, m.id AS menu_id, m.name AS menu_name, m.price
FROM category c
LEFT JOIN menu m
ON c.id = m.category_id
ORDER BY c.id, m.id;


-- 3. 집계

-- query 1. 주문 상태별 주문 수 조회 (COUNT, GROUP BY 사용)
-- description: 주문 상태별 주문 수 조회
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY status;

-- query 2. 주문 상태별 주문 금액 합계 조회 (SUM, GROUP BY 사용)
-- description: 주문 상태별로 주문 상세 금액의 합계를 계산
SELECT o.status, SUM(oi.unit_price * oi.quantity) AS total_order_amount
FROM orders o
INNER JOIN order_item oi 
ON o.id = oi.order_id
GROUP BY o.status
ORDER BY o.status;

-- query 3. 카테고리별 평균 메뉴 가격 조회 (AVG, GROUP BY 사용)
-- description: 카테고리별 메뉴 평균 가격 계산
SELECT c.name AS category_name, AVG(m.price) AS average_menu_price
FROM category c
INNER JOIN menu m
ON c.id = m.category_id
GROUP BY c.id, c.name
ORDER BY c.id;

-- query 4. 고객별 주문 수 조회 (COUNT, GROUP BY, LEFT JOIN 사용)
-- description: 고객별 주문 건수 조회
SELECT c.id AS id, c.name AS name, COUNT(o.id) AS order_count
FROM customer c
LEFT JOIN orders o
ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY c.id;


-- 4. 서브쿼리

-- query 1. 평균 가격보다 비싼 메뉴 조회
-- description: menu 테이블의 평균 가격보다 비싼 가격의 메뉴 조회
SELECT id, name, price
FROM menu
WHERE price > (
    SELECT AVG(price)
    FROM menu
)
ORDER BY price DESC, id ASC;


-- 5. 데이터 수정 및 삭제

-- query 1. 메뉴 가격 수정 (UPDATE 사용)
-- description: 아메리카노 가격을 3500원에서 4000원으로 수정
UPDATE menu
SET price = 4000
WHERE name = '아메리카노';

-- UPDATE 확인
SELECT id, name, price
FROM menu
WHERE name = '아메리카노';

-- query 2. 취소 주문의 주문 상세 삭제 (DELETE 사용)
-- description: CANCELED 상태인 5번 주문의 주문 상세 데이터 삭제
DELETE 
FROM order_item
WHERE order_id IN (
    SELECT id
    FROM orders
    WHERE id = 5 AND status = 'CANCELED'
)

-- DELETE 확인
SELECT *
FROM order_item
WHERE order_id = 5;


-- 6. 인덱스 

-- query 1. 고객별 주문 조회 성능 개선을 위한 인덱스 생성
-- 적용 이유: orders.customer_id는 customer와 JOIN하거나 특정 고객의 주문 이력을 조회할 때 자주 사용되므로 인덱스를 생성한다.
CREATE INDEX IF NOT EXISTS idx_orders_customer_id
ON orders (customer_id);

-- sqlite_master에서 생성된 인덱스 정보를 조회
SELECT name, tbl_name, sql
FROM sqlite_master
WHERE type = 'index' AND name = 'idx_orders_customer_id';
