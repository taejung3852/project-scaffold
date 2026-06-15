# ambiguity-check — Intent Routing 진입점

`/setup` 인터뷰의 모든 서브 질문에 대해 실행되는 서브스킬.
질문을 던지기 **전** 아래 3-way routing으로 처리 경로를 결정한다.

---

## Routing 테이블

| 분류 | 조건 | 참조 |
|---|---|---|
| **CLEAR** | 원하는 결과가 명확, 열린 항목은 선호·트레이드오프뿐 | `references/clear-path.md` |
| **UNCLEAR** | 결과 자체가 모호하거나 아직 미결정 | `references/unclear-path.md` |
| **FENCE** | CLEAR/UNCLEAR 구분 불명확 | CLEAR로 처리 + 딱 하나의 질문만 |

> 불확실하면 **CLEAR로** 빠진다. 잘못 침묵시키는 것이 하나 더 묻는 것보다 나쁘다.
