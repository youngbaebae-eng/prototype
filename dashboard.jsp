 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/WEB-INF/views/dashboard.jsp b/WEB-INF/views/dashboard.jsp
new file mode 100644
index 0000000000000000000000000000000000000000..0f36de6e6cdc5fd3b357da3d7a36415f4e66503d
--- /dev/null
+++ b/WEB-INF/views/dashboard.jsp
@@ -0,0 +1,525 @@
+<%@ page contentType="text/html; charset=UTF-8" %>
+<!DOCTYPE html>
+<html lang="ko">
+<head>
+  <meta charset="UTF-8">
+  <meta name="viewport" content="width=device-width, initial-scale=1.0">
+  <title>공동주택 관리 ERP - 자동화 운영관리 대시보드</title>
+  <link
+    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
+    rel="stylesheet"
+    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
+    crossorigin="anonymous"
+  >
+  <style>
+    body {
+      background-color: #f4f6f9;
+    }
+    .sidebar {
+      min-height: 100vh;
+      background-color: #ffffff;
+      border-right: 1px solid #e0e6ed;
+    }
+    .sidebar .nav-link {
+      color: #344767;
+    }
+    .sidebar .nav-link.active {
+      background-color: #e7f1ff;
+      color: #0d6efd;
+      font-weight: 600;
+    }
+    .summary-card {
+      border: none;
+      border-radius: 12px;
+      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.05);
+    }
+    .table-fixed thead th {
+      position: sticky;
+      top: 0;
+      background-color: #f8fafc;
+      z-index: 1;
+    }
+    .table-scroll {
+      max-height: 280px;
+      overflow-y: auto;
+    }
+    .alert-area {
+      position: sticky;
+      top: 0;
+      z-index: 1030;
+    }
+    .badge-soft {
+      background-color: rgba(13, 110, 253, 0.12);
+      color: #0d6efd;
+    }
+  </style>
+</head>
+<body>
+  <!-- 상단 고정 헤더 -->
+  <header class="navbar navbar-expand-lg navbar-light bg-white border-bottom shadow-sm sticky-top">
+    <div class="container-fluid">
+      <a class="navbar-brand fw-bold text-primary" href="#">공동주택 ERP 자동화 대시보드</a>
+      <form class="d-flex ms-auto me-3" role="search">
+        <input class="form-control form-control-sm" type="search" placeholder="검색" aria-label="Search">
+      </form>
+      <ul class="navbar-nav mb-2 mb-lg-0 align-items-center">
+        <li class="nav-item me-3">
+          <span class="text-muted">홍길동 (회계 담당)</span>
+        </li>
+        <li class="nav-item me-2">
+          <button class="btn btn-outline-primary btn-sm">알림</button>
+        </li>
+        <li class="nav-item">
+          <button class="btn btn-primary btn-sm">내정보</button>
+        </li>
+      </ul>
+    </div>
+  </header>
+
+  <div class="container-fluid">
+    <div class="row">
+      <!-- 좌측 사이드바 -->
+      <nav class="col-md-2 d-none d-md-block sidebar p-3">
+        <h6 class="text-uppercase text-muted">메뉴</h6>
+        <ul class="nav flex-column">
+          <li class="nav-item">
+            <a class="nav-link active" href="#">대시보드</a>
+          </li>
+          <li class="nav-item">
+            <a class="nav-link" href="#">자동분개</a>
+          </li>
+          <li class="nav-item">
+            <a class="nav-link" href="#">자동부과</a>
+          </li>
+          <li class="nav-item">
+            <a class="nav-link" href="#">통계관리</a>
+          </li>
+        </ul>
+      </nav>
+
+      <!-- 메인 콘텐츠 -->
+      <main class="col-md-10 ms-sm-auto px-md-4 py-4">
+        <div class="alert-area" id="alertArea"></div>
+
+        <!-- 상단 필터 -->
+        <section class="mb-4">
+          <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
+            <div>
+              <h4 class="fw-bold">자동화 운영관리 현황</h4>
+              <p class="text-muted mb-0">단지별 자동 수납 및 전표 처리 흐름을 한눈에 확인하세요.</p>
+            </div>
+            <div class="d-flex align-items-center gap-2">
+              <label for="complexSelect" class="form-label mb-0 text-muted">단지 선택</label>
+              <select id="complexSelect" class="form-select form-select-sm" style="min-width: 200px;"></select>
+            </div>
+          </div>
+        </section>
+
+        <!-- 상단 요약 카드 -->
+        <section class="row g-3 mb-4" id="summaryCards"></section>
+
+        <!-- 중앙 영역 -->
+        <section class="row g-4 mb-4">
+          <div class="col-lg-6">
+            <div class="card shadow-sm">
+              <div class="card-header bg-white">
+                <div class="d-flex justify-content-between align-items-center">
+                  <h6 class="mb-0 fw-bold">단지별 자동처리 현황</h6>
+                  <span class="badge badge-soft">실시간</span>
+                </div>
+              </div>
+              <div class="table-scroll">
+                <table class="table table-striped table-fixed mb-0" id="complexTable">
+                  <thead>
+                    <tr>
+                      <th>단지명</th>
+                      <th class="text-end">자동처리</th>
+                      <th class="text-end">미처리</th>
+                      <th class="text-end">승인 대기</th>
+                    </tr>
+                  </thead>
+                  <tbody></tbody>
+                </table>
+              </div>
+            </div>
+          </div>
+          <div class="col-lg-6">
+            <div class="card shadow-sm h-100">
+              <div class="card-header bg-white">
+                <h6 class="mb-0 fw-bold" id="detailTitle">자동처리 기준 내역</h6>
+              </div>
+              <div class="card-body" id="detailPanel"></div>
+            </div>
+          </div>
+        </section>
+
+        <!-- 하단 공지 및 알림 -->
+        <section class="row g-4">
+          <div class="col-lg-8">
+            <div class="card shadow-sm">
+              <div class="card-header bg-white">
+                <h6 class="mb-0 fw-bold">단지별 공지 사항</h6>
+              </div>
+              <div class="table-responsive">
+                <table class="table mb-0" id="noticeTable">
+                  <thead>
+                    <tr>
+                      <th>단지명</th>
+                      <th>공지 내용</th>
+                      <th>등록일</th>
+                    </tr>
+                  </thead>
+                  <tbody></tbody>
+                </table>
+              </div>
+            </div>
+          </div>
+          <div class="col-lg-4">
+            <div class="card shadow-sm">
+              <div class="card-header bg-white">
+                <h6 class="mb-0 fw-bold">알림</h6>
+              </div>
+              <ul class="list-group list-group-flush" id="alertList"></ul>
+            </div>
+          </div>
+        </section>
+      </main>
+    </div>
+  </div>
+
+  <script>
+    /* 대시보드 초기화 및 상태 관리 */
+    (function () {
+      const state = {
+        complexes: [],
+        summary: {},
+        selectedComplexId: null,
+        notices: [],
+        alerts: []
+      };
+
+      const elements = {
+        summaryCards: document.querySelector('#summaryCards'),
+        complexSelect: document.querySelector('#complexSelect'),
+        complexTableBody: document.querySelector('#complexTable tbody'),
+        detailPanel: document.querySelector('#detailPanel'),
+        detailTitle: document.querySelector('#detailTitle'),
+        noticeTableBody: document.querySelector('#noticeTable tbody'),
+        alertList: document.querySelector('#alertList'),
+        alertArea: document.querySelector('#alertArea')
+      };
+
+      /* 더미 데이터 로드 */
+      function loadMockData() {
+        // TODO: API 연동 시 이 부분 교체
+        return Promise.resolve({
+          summary: {
+            totalComplexes: 12,
+            autoRate: 78.4,
+            manualRate: 21.6,
+            pendingApprovals: 34
+          },
+          complexes: [
+            {
+              id: 'C001',
+              name: '해봄타운',
+              auto: 124,
+              manual: 12,
+              pending: 4,
+              details: [
+                {
+                  title: '수납 처리 자동전표 현황',
+                  items: [
+                    '자동전표 현황: 3건',
+                    '미처리 현황: 가수금 전표 자동 생성 → 사용자 확인 → 수기 자동 상계 처리 → 패턴 저장 확인'
+                  ]
+                },
+                {
+                  title: '고정 지출 자동전표 현황',
+                  items: [
+                    '매월 반복되는 지출 기반 자동 전표 생성',
+                    '공과금(전기, 수도, 통신비) 및 세금',
+                    '급여, 인건비',
+                    '유지보수, 각종 수수료'
+                  ]
+                },
+                {
+                  title: '증빙 자료 자동전표 현황',
+                  items: [
+                    '고지서 및 지로 영수증, 세금계산서',
+                    '간이영수증 이미지'
+                  ]
+                },
+                {
+                  title: '선급비용 자동전표 현황',
+                  items: ['선급비용 항목별 차수표기(3회/12)']
+                }
+              ]
+            },
+            {
+              id: 'C002',
+              name: '늘봄파크',
+              auto: 98,
+              manual: 20,
+              pending: 8,
+              details: [
+                {
+                  title: '수납 처리 자동전표 현황',
+                  items: [
+                    '자동전표 현황: 2건',
+                    '미처리 현황: 가수금 전표 자동 생성 → 사용자 확인 → 수기 자동 상계 처리 → 패턴 저장 확인'
+                  ]
+                },
+                {
+                  title: '고정 지출 자동전표 현황',
+                  items: [
+                    '매월 반복되는 지출 기반 자동 전표 생성',
+                    '공과금(전기, 수도, 통신비) 및 세금',
+                    '급여, 인건비'
+                  ]
+                },
+                {
+                  title: '증빙 자료 자동전표 현황',
+                  items: ['고지서 및 지로 영수증, 세금계산서']
+                },
+                {
+                  title: '선급비용 자동전표 현황',
+                  items: ['선급비용 항목별 차수표기(7회/12)']
+                }
+              ]
+            },
+            {
+              id: 'C003',
+              name: '푸른마을',
+              auto: 142,
+              manual: 18,
+              pending: 6,
+              details: [
+                {
+                  title: '수납 처리 자동전표 현황',
+                  items: [
+                    '자동전표 현황: 5건',
+                    '미처리 현황: 가수금 전표 자동 생성 → 사용자 확인 → 수기 자동 상계 처리 → 패턴 저장 확인'
+                  ]
+                },
+                {
+                  title: '고정 지출 자동전표 현황',
+                  items: [
+                    '매월 반복되는 지출 기반 자동 전표 생성',
+                    '공과금(전기, 수도, 통신비) 및 세금',
+                    '급여, 인건비',
+                    '유지보수, 각종 수수료'
+                  ]
+                },
+                {
+                  title: '증빙 자료 자동전표 현황',
+                  items: [
+                    '고지서 및 지로 영수증, 세금계산서',
+                    '간이영수증 이미지'
+                  ]
+                },
+                {
+                  title: '선급비용 자동전표 현황',
+                  items: ['선급비용 항목별 차수표기(1회/12)']
+                }
+              ]
+            }
+          ],
+          notices: [
+            { complex: '해봄타운', message: '2024년 10월 장기수선충당금 자동분개 기준 업데이트', date: '2024-10-02' },
+            { complex: '늘봄파크', message: '수납 자동처리 패턴 신규 등록 요청 2건 확인 필요', date: '2024-10-01' },
+            { complex: '푸른마을', message: '미처리 전표 승인 대기 6건 발생', date: '2024-09-30' }
+          ],
+          alerts: [
+            '미처리 전표 14건이 48시간 이상 유지 중입니다.',
+            '수기 승인 대기 3건이 오늘 마감 예정입니다.',
+            '새로운 자동전표 분개 패턴 1건이 추천되었습니다.'
+          ]
+        });
+      }
+
+      /* 요약 카드 렌더링 */
+      function renderSummaryCards(summary) {
+        const cards = [
+          { title: '전체 단지 수', value: `${summary.totalComplexes}개`, note: '운영중 단지' },
+          { title: '전체 자동처리율', value: `${summary.autoRate}%`, note: '전월 대비 +2.3%p' },
+          { title: '전체 자동 미처리율', value: `${summary.manualRate}%`, note: '미처리 사유 확인 필요' },
+          { title: '수기승인 대기', value: `${summary.pendingApprovals}건`, note: '48시간 이내 처리 권장' }
+        ];
+
+        elements.summaryCards.innerHTML = cards
+          .map(
+            (card) => `
+              <div class="col-md-6 col-xl-3">
+                <div class="card summary-card">
+                  <div class="card-body">
+                    <p class="text-muted mb-1">${card.title}</p>
+                    <h4 class="fw-bold mb-1">${card.value}</h4>
+                    <small class="text-primary">${card.note}</small>
+                  </div>
+                </div>
+              </div>
+            `
+          )
+          .join('');
+      }
+
+      /* 단지 리스트 렌더링 */
+      function renderComplexTable(complexes) {
+        if (!complexes.length) {
+          elements.complexTableBody.innerHTML = `
+            <tr>
+              <td colspan="4" class="text-center text-muted">데이터가 없습니다</td>
+            </tr>
+          `;
+          return;
+        }
+
+        elements.complexTableBody.innerHTML = complexes
+          .map(
+            (complex) => `
+              <tr data-complex-id="${complex.id}" style="cursor: pointer;">
+                <td>${complex.name}</td>
+                <td class="text-end">${complex.auto}건</td>
+                <td class="text-end">${complex.manual}건</td>
+                <td class="text-end">${complex.pending}건</td>
+              </tr>
+            `
+          )
+          .join('');
+      }
+
+      /* 상세 패널 렌더링 */
+      function renderDetailPanel(complex) {
+        if (!complex) {
+          elements.detailPanel.innerHTML = '<p class="text-muted">단지를 선택하세요.</p>';
+          return;
+        }
+
+        elements.detailTitle.textContent = `${complex.name} 자동처리 기준 내역`;
+        elements.detailPanel.innerHTML = complex.details
+          .map(
+            (detail) => `
+              <div class="mb-3">
+                <h6 class="fw-bold">${detail.title}</h6>
+                <ul class="text-muted">
+                  ${detail.items.map((item) => `<li>${item}</li>`).join('')}
+                </ul>
+              </div>
+            `
+          )
+          .join('');
+      }
+
+      /* 공지사항 렌더링 */
+      function renderNotices(notices) {
+        if (!notices.length) {
+          elements.noticeTableBody.innerHTML = `
+            <tr>
+              <td colspan="3" class="text-center text-muted">데이터가 없습니다</td>
+            </tr>
+          `;
+          return;
+        }
+
+        elements.noticeTableBody.innerHTML = notices
+          .map(
+            (notice) => `
+              <tr>
+                <td>${notice.complex}</td>
+                <td>${notice.message}</td>
+                <td>${notice.date}</td>
+              </tr>
+            `
+          )
+          .join('');
+      }
+
+      /* 알림 리스트 렌더링 */
+      function renderAlerts(alerts) {
+        if (!alerts.length) {
+          elements.alertList.innerHTML = '<li class="list-group-item text-muted">데이터가 없습니다</li>';
+          return;
+        }
+
+        elements.alertList.innerHTML = alerts
+          .map((alert) => `<li class="list-group-item">${alert}</li>`)
+          .join('');
+      }
+
+      /* 필터 드롭다운 렌더링 */
+      function renderComplexSelect(complexes) {
+        elements.complexSelect.innerHTML = complexes
+          .map((complex) => `<option value="${complex.id}">${complex.name}</option>`)
+          .join('');
+      }
+
+      /* 이벤트 바인딩 */
+      function bindEvents() {
+        elements.complexSelect.addEventListener('change', (event) => {
+          state.selectedComplexId = event.target.value;
+          updateDetailPanel();
+        });
+
+        elements.complexTableBody.addEventListener('click', (event) => {
+          const row = event.target.closest('tr');
+          if (!row) {
+            return;
+          }
+          const complexId = row.getAttribute('data-complex-id');
+          state.selectedComplexId = complexId;
+          elements.complexSelect.value = complexId;
+          updateDetailPanel();
+        });
+      }
+
+      /* 상세 패널 갱신 */
+      function updateDetailPanel() {
+        const complex = state.complexes.find((item) => item.id === state.selectedComplexId);
+        renderDetailPanel(complex);
+      }
+
+      /* 에러 알림 출력 */
+      function showError(message) {
+        elements.alertArea.innerHTML = `
+          <div class="alert alert-danger alert-dismissible fade show" role="alert">
+            ${message}
+            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
+          </div>
+        `;
+      }
+
+      /* 대시보드 초기화 */
+      function initDashboard() {
+        loadMockData()
+          .then((data) => {
+            state.summary = data.summary;
+            state.complexes = data.complexes;
+            state.notices = data.notices;
+            state.alerts = data.alerts;
+            state.selectedComplexId = data.complexes[0]?.id || null;
+
+            renderSummaryCards(state.summary);
+            renderComplexSelect(state.complexes);
+            renderComplexTable(state.complexes);
+            renderDetailPanel(state.complexes[0]);
+            renderNotices(state.notices);
+            renderAlerts(state.alerts);
+            elements.complexSelect.value = state.selectedComplexId || '';
+          })
+          .catch(() => {
+            showError('데이터를 불러오지 못했습니다. 관리자에게 문의하세요.');
+          });
+      }
+
+      bindEvents();
+      initDashboard();
+    })();
+  </script>
+  <script
+    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
+    integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
+    crossorigin="anonymous"
+  ></script>
+</body>
+</html>
 
EOF
)