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
