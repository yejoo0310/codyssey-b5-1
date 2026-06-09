PRAGMA foreign_keys = ON;

-- 1. 조인 1개를 두 방식으로 풀기
-- description: 주문 이력이 있는 고객 조회

-- query 1. JOIN 방식
SELECT DISTINCT
    c.id AS customer_id,
    c.name AS customer_name,
    c.phone,
    c.email
FROM customer c
INNER JOIN orders o
ON c.id = o.customer_id
ORDER BY c.id;

-- query 2. 서브 쿼리 방식
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

/*
JOIN과 서브쿼리 방식의 차이점

JOIN 방식은 customer와 orders를 직접 연결하므로 두 테이블의 컬럼을 함께 조회하기 좋다.
예를 들어 고객명과 주문일, 주문상태를 한 번에 보고 싶을 때 적합하다.

서브쿼리 방식은 "특정 조건을 만족하는 대상만 필터링"할 때 읽기 쉽다.
이번 예시에서는 주문 이력이 있는 고객 id 목록을 먼저 구하고, 그 목록에 포함된 고객만 조회한다.

현재 요구사항처럼 고객 정보만 필요하면 서브쿼리 방식도 충분히 명확하다.
하지만 주문 정보까지 함께 출력해야 한다면 JOIN 방식이 더 적합하다.
*/


-- 2. 데이터 정합성 깨뜨려 보기

-- FK 에러가 나는 쿼리
-- description: order_item.menu_id는 menu.id를 참조한다. 그러나 현재 menu 테이블에 id=999인 메뉴가 없다.
-- 따라서 order_item이 존재하지 않는 메뉴를 참조하게 되므로 FK 제약조건에 의해 입력이 막히게 된다.
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

-- 고치는 방법 1: 존재하는 menu_id 사용
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

SELECT *
FROM order_item;

DELETE FROM order_item
WHERE id = 100;

-- 고치는 방법 2: 먼저 부모 데이터 입력 후 자식 데이터 입력
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

SELECT *
FROM order_item;

DELETE FROM order_item
WHERE id = 100;

DELETE FROM menu
WHERE id = 999;

/*
order_item.menu_id는 menu.id를 참조하는 FK이다.
존재하지 않는 menu_id = 999를 order_item에 입력하려고 하면 참조 대상이 없기 때문에 FOREIGN KEY constraint failed 에러가 발생한다.

이를 해결하려면 두 가지 방법이 있다.
첫째, 이미 존재하는 menu_id를 사용한다.
둘째, menu 테이블에 부모 데이터를 먼저 입력한 뒤 order_item에 자식 데이터를 입력한다.

FK 제약조건은 잘못된 참조 데이터가 저장되는 것을 막아 데이터 정합성을 보장한다.
*/