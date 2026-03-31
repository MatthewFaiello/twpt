#--------------------------- ui ----------------------------------------------#

ui <- page_sidebar(
  window_title = "Teacher Workforce Planning Tool",
  fillable = TRUE,
  fillable_mobile = TRUE,
  
  useShinyjs(),
  
  tags$script(HTML("
    $(document).on('click', '#plot1Export', function () {
      Shiny.setInputValue('download_clicked', Math.random());
    });
  ")),
  
  tags$style(HTML("
    :root {
      --dde-blue: #194a78;
      --dde-blue-dark: #123758;
      --dde-orange: #d98b00;
      --dde-orange-soft: #fff7ea;
      --dde-bg: #f5f7fb;
      --dde-surface: #ffffff;
      --dde-surface-soft: #fbfcfe;
      --dde-border: #d8e2ec;
      --dde-border-strong: #c7d5e2;
      --dde-text: #1f2937;
      --dde-muted: #5b6875;
      --dde-shadow: 0 8px 24px rgba(17, 24, 39, 0.05);
      --dde-shadow-lg: 0 14px 32px rgba(17, 24, 39, 0.10);
      --dde-radius: 16px;
      --dde-radius-sm: 12px;
      --dde-control-height: 44px;
      --dde-control-height-sm: 42px;
      --dde-focus-ring: 0 0 0 0.15rem rgba(25, 74, 120, 0.14);
    }

    html, body {
      background-color: var(--dde-bg);
      color: var(--dde-text);
    }

    body {
      font-size: 15px;
      line-height: 1.45;
    }

    .bslib-page-sidebar {
      background-color: var(--dde-bg);
    }

    .shiny-output-error {
      visibility: hidden;
    }

    .shiny-output-error:before {
      visibility: visible;
      content: 'We’re updating the forecast. Please wait a moment.';
      color: var(--dde-blue);
      font-weight: 600;
    }

    .shiny-input-container {
      margin-bottom: 0.9rem;
      min-width: 0;
    }

    .form-label,
    .shiny-input-container > label {
      display: block;
      font-weight: 700;
      margin-bottom: 0.38rem;
      color: var(--dde-text);
      font-size: 0.92rem;
      line-height: 1.25;
    }

    .btn {
      border-radius: 10px;
      font-weight: 650;
      transition: all 0.18s ease;
    }

    .btn:focus,
    .accordion-button:focus,
    .form-control:focus,
    .form-select:focus,
    .bootstrap-select .dropdown-toggle:focus,
    input[type='number']:focus {
      box-shadow: var(--dde-focus-ring) !important;
    }

    .form-control,
    .form-select,
    input[type='number'],
    .bootstrap-select > .dropdown-toggle,
    .input-group > .form-control,
    .input-group > input[type='number'] {
      min-height: var(--dde-control-height);
      border: 1px solid var(--dde-border);
      border-radius: 12px;
      background: #fff;
      color: var(--dde-text);
      font-size: 0.95rem;
      font-weight: 600;
      line-height: 1.2;
      box-shadow: none !important;
      transition: all 0.18s ease;
    }

    .form-control,
    .form-select,
    input[type='number'],
    .input-group > .form-control,
    .input-group > input[type='number'] {
      padding: 0.55rem 0.8rem;
    }

    /* Keep native numeric spinners visible and comfortable */
    input[type='number'] {
      appearance: auto;
      -webkit-appearance: auto;
      -moz-appearance: auto;
      padding-right: 0.45rem;
    }

    input[type='number']::-webkit-outer-spin-button,
    input[type='number']::-webkit-inner-spin-button {
      -webkit-appearance: auto;
      margin: 0;
    }

    .form-control:hover,
    .form-select:hover,
    input[type='number']:hover,
    .bootstrap-select > .dropdown-toggle:hover,
    .input-group > .form-control:hover,
    .input-group > input[type='number']:hover,
    .accordion-button:hover {
      border-color: var(--dde-orange);
      background: var(--dde-orange-soft);
      color: var(--dde-blue);
    }

    .form-control:focus,
    .form-select:focus,
    input[type='number']:focus,
    .bootstrap-select.show > .dropdown-toggle,
    .bootstrap-select .dropdown-toggle:focus,
    .bootstrap-select > .dropdown-toggle:active,
    .input-group > .form-control:focus,
    .input-group > input[type='number']:focus {
      border-color: var(--dde-blue);
      background: #fff;
      outline: none;
      color: var(--dde-text);
    }

    .bslib-sidebar-layout > .sidebar {
      background: var(--dde-surface);
      border-right: 1px solid var(--dde-border);
      padding: 0.95rem 1rem 1rem 1rem;
      min-width: 260px;
      max-width: 500px;
    }

    .brand-wrap {
      text-align: center;
      padding: 0.15rem 0 0.85rem 0;
      margin-bottom: 0.8rem;
      border-bottom: 1px solid var(--dde-border);
    }

    .brand-logo {
      max-width: 100%;
      width: 225px;
      height: auto;
      display: inline-block;
    }

    .brand-caption {
      margin-top: 0.5rem;
      font-size: 1rem;
      font-weight: 750;
      color: var(--dde-blue);
      letter-spacing: 0.01em;
    }

    .brand-subcaption {
      margin-top: 0.2rem;
      font-size: 0.88rem;
      color: var(--dde-muted);
    }

    .sidebar-section {
      background: var(--dde-surface-soft);
      border: 1px solid var(--dde-border);
      border-radius: var(--dde-radius);
      padding: 0.95rem 0.95rem 0.25rem 0.95rem;
      margin-bottom: 0.95rem;
    }

    .section-kicker {
      font-size: 0.74rem;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      color: var(--dde-orange);
      margin-bottom: 0.15rem;
    }

    .section-title {
      font-size: 1rem;
      font-weight: 750;
      color: var(--dde-blue);
      margin-bottom: 0.8rem;
    }

    .control-block {
      margin-bottom: 0.95rem;
    }

    .control-block:last-child {
      margin-bottom: 0.7rem;
    }

    .bootstrap-select {
      width: 100% !important;
      max-width: 100%;
    }

    .bootstrap-select > .dropdown-toggle {
      padding: 0.55rem 0.85rem;
      max-width: 100%;
    }

    .bootstrap-select .filter-option {
      display: flex;
      align-items: center;
      min-width: 0;
    }

    .bootstrap-select .filter-option-inner {
      min-width: 0;
      width: 100%;
    }

    .bootstrap-select .filter-option-inner-inner {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .bootstrap-select .dropdown-toggle::after {
      border-top-color: var(--dde-muted);
      margin-left: 0.5rem;
    }

    .bootstrap-select.show .dropdown-toggle::after {
      border-top-color: var(--dde-blue);
    }

    .bootstrap-select .dropdown-menu {
      border: 1px solid var(--dde-border);
      border-radius: 14px;
      padding: 0.4rem;
      box-shadow: var(--dde-shadow-lg);
      background: var(--dde-surface);
      overflow: hidden;
      width: 100%;
      min-width: 100%;
      max-width: 100%;
    }

    .bootstrap-select .dropdown-menu .inner {
      max-height: 260px !important;
      overflow-y: auto !important;
      overflow-x: hidden !important;
      border-radius: 10px;
    }

    .bootstrap-select .dropdown-menu li a {
      border-radius: 10px;
      padding: 0.55rem 0.7rem;
      color: var(--dde-text);
      font-weight: 500;
      transition: background-color 0.15s ease, color 0.15s ease;
      white-space: normal !important;
      word-break: break-word;
      overflow-wrap: anywhere;
    }

    .bootstrap-select .dropdown-menu li a .text {
      white-space: normal !important;
      word-break: break-word;
      overflow-wrap: anywhere;
    }

    .bootstrap-select .dropdown-menu li a:hover,
    .bootstrap-select .dropdown-menu li a:focus {
      background: var(--dde-orange-soft);
      color: var(--dde-blue);
    }

    .bootstrap-select .dropdown-menu li.selected a {
      background: var(--dde-orange-soft);
      color: var(--dde-blue);
      font-weight: 700;
    }

    .bootstrap-select .bs-searchbox {
      padding: 0.35rem 0.35rem 0.5rem 0.35rem;
      border-bottom: 1px solid #eef2f7;
      margin-bottom: 0.25rem;
    }

    .bootstrap-select .bs-searchbox input {
      min-height: 38px;
      border: 1px solid var(--dde-border);
      border-radius: 10px;
      padding: 0.45rem 0.7rem;
      color: var(--dde-text);
    }

    .bootstrap-select .bs-searchbox input:focus {
      border-color: var(--dde-blue);
      box-shadow: 0 0 0 0.15rem rgba(25, 74, 120, 0.10);
      outline: none;
    }

    .bootstrap-select .no-results {
      padding: 0.65rem 0.75rem;
      color: var(--dde-muted);
      font-size: 0.9rem;
      background: transparent;
    }

    .target-group .shiny-input-container > label {
      font-size: 0.82rem;
      font-weight: 750;
      color: var(--dde-muted);
      margin-bottom: 0.28rem;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }

    .target-group .input-group {
      width: 100%;
      flex-wrap: nowrap;
      border-radius: 12px;
    }

    .target-group .input-group > .input-group-text,
    .target-group .input-group > .btn,
    .target-group .input-group > .input-group-addon,
    .target-group .input-group .input-group-text {
      min-height: var(--dde-control-height);
      border: 1px solid var(--dde-border);
      background: #f7fafc;
      color: var(--dde-blue);
      font-weight: 700;
      padding: 0.55rem 0.75rem;
      box-shadow: none !important;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex: 0 0 auto;
      transition: all 0.18s ease;
    }

    .target-group .input-group > .input-group-text:first-child,
    .target-group .input-group > .btn:first-child,
    .target-group .input-group > .input-group-addon:first-child {
      border-right: 0;
      border-radius: 12px 0 0 12px;
    }

    .target-group .input-group > .input-group-text:last-child,
    .target-group .input-group > .btn:last-child,
    .target-group .input-group > .input-group-addon:last-child {
      border-left: 0;
      border-radius: 0 12px 12px 0;
    }

    .target-group .input-group > .form-control,
    .target-group .input-group > input[type='number'] {
      border-radius: 0 12px 12px 0;
      border-left: 0;
      padding-left: 0.8rem;
    }

    .target-group .input-group > input[type='number'] {
      padding-right: 0.6rem;
    }

    .target-group .input-group > .form-control:hover,
    .target-group .input-group > input[type='number']:hover {
      border-color: var(--dde-border);
      background: var(--dde-orange-soft);
      color: var(--dde-blue);
    }

    .target-group .input-group:focus-within > .input-group-text,
    .target-group .input-group:focus-within > .btn,
    .target-group .input-group:focus-within > .input-group-addon {
      border-color: var(--dde-blue);
      background: #f4f8fc;
      color: var(--dde-blue);
    }

    .target-group input[type='number']:not(.input-group input) {
      width: 100%;
    }

    .control-note {
      font-size: 0.81rem;
      color: var(--dde-muted);
      line-height: 1.35;
      margin-top: 0.28rem;
      margin-bottom: 0;
    }

    .info-callout {
      background: #f8fbff;
      border: 1px solid var(--dde-border);
      border-left: 4px solid var(--dde-blue);
      border-radius: 12px;
      padding: 0.75rem 0.85rem;
      color: var(--dde-text);
      font-size: 0.86rem;
      line-height: 1.4;
      margin-top: 0.1rem;
      margin-bottom: 0.85rem;
    }

    .accordion {
      --bs-accordion-border-color: transparent;
      --bs-accordion-btn-focus-box-shadow: none;
      --bs-accordion-border-radius: 12px;
      --bs-accordion-inner-border-radius: 12px;
    }

    .accordion-item {
      border: 1px solid var(--dde-border);
      border-radius: 12px;
      overflow: hidden;
      margin-bottom: 0.75rem;
      background: var(--dde-surface);
    }

    .accordion-button {
      background: var(--dde-surface);
      color: var(--dde-text);
      font-weight: 750;
      font-size: 0.96rem;
      padding: 0.85rem 0.95rem;
      transition: all 0.18s ease;
    }

    .accordion-button:not(.collapsed) {
      background: #f4f8fc;
      color: var(--dde-blue);
    }

    .accordion-body {
      padding: 0.9rem;
      background: #fcfdff;
    }

    .target-group {
      background: var(--dde-surface);
      border: 1px solid var(--dde-border);
      border-radius: 14px;
      padding: 0.95rem 0.95rem 0.3rem 0.95rem;
      margin-bottom: 0.9rem;
      box-shadow: 0 2px 8px rgba(17, 24, 39, 0.03);
      transition: all 0.18s ease;
    }

    .target-group:hover {
      border-color: var(--dde-border-strong);
      border-left: 4px solid var(--dde-orange);
    }

    .subsection-title {
      font-size: 0.96rem;
      font-weight: 800;
      color: var(--dde-blue);
      margin-bottom: 0.7rem;
      line-height: 1.25;
    }

    .sidebar-footer {
      margin-top: 0.6rem;
      padding-top: 0.75rem;
      border-top: 1px solid var(--dde-border);
    }

    .sidebar-footer .btn {
      width: 100%;
      background: var(--dde-surface);
      border: 1px solid var(--dde-border);
      color: var(--dde-blue);
      padding-top: 0.65rem;
      padding-bottom: 0.65rem;
      min-height: var(--dde-control-height);
    }

    .sidebar-footer .btn:hover,
    .sidebar-footer .btn:focus {
      background: var(--dde-orange-soft);
      border-color: var(--dde-orange);
      color: var(--dde-blue);
    }

    .main-stack {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
      padding-top: 0.05rem;
      min-width: 0;
    }

    .navset-card-underline,
    .card {
      border: 1px solid var(--dde-border);
      border-radius: 16px;
      box-shadow: var(--dde-shadow);
      overflow: hidden;
      background: var(--dde-surface);
      min-width: 0;
    }

    .navset-card-underline > .card-header {
      background: var(--dde-surface);
      border-bottom: 1px solid var(--dde-border);
      padding: 0.55rem 0.85rem 0 0.85rem !important;
      justify-content: flex-start !important;
    }

    .nav-underline,
    .nav-underline .nav {
      justify-content: flex-start !important;
      margin-left: 0 !important;
      gap: 0.15rem;
      flex-wrap: wrap;
    }

    .nav-underline .nav-link {
      color: var(--dde-muted);
      font-weight: 700;
      border-bottom: 3px solid transparent;
      padding-left: 0.75rem;
      padding-right: 0.75rem;
      padding-bottom: 0.7rem;
    }

    .nav-underline .nav-link:hover {
      color: var(--dde-blue);
      border-bottom-color: var(--dde-orange);
      background: transparent;
    }

    .nav-underline .nav-link.active {
      color: var(--dde-blue);
      border-bottom-color: var(--dde-orange);
      background: transparent;
    }

    .tab-pane {
      padding: 0.6rem 0.75rem 0.75rem 0.75rem;
      min-width: 0;
    }

    .panel-shell {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
      min-width: 0;
    }

    .panel-card {
      border: 1px solid var(--dde-border);
      border-radius: 16px;
      background: var(--dde-surface);
      box-shadow: var(--dde-shadow);
      overflow: hidden;
      min-width: 0;
    }

    .panel-card-header {
      padding: 0.8rem 0.95rem 0.7rem 0.95rem;
      border-bottom: 1px solid var(--dde-border);
      background: linear-gradient(180deg, #ffffff 0%, #fbfcff 100%);
    }

    .panel-title {
      font-size: clamp(0.95rem, 1vw + 0.65rem, 1.15rem);
      font-weight: 800;
      color: var(--dde-blue);
      margin-bottom: 0.1rem;
      line-height: 1.2;
    }

    .panel-subtitle {
      color: var(--dde-muted);
      margin-bottom: 0;
      font-size: clamp(0.82rem, 0.4vw + 0.72rem, 0.95rem);
      line-height: 1.35;
    }

    .panel-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 0.75rem;
      flex-wrap: wrap;
      min-width: 0;
    }

    .panel-header-text {
      flex: 1 1 22rem;
      min-width: 0;
    }

    .panel-header-controls {
      flex: 1 1 18rem;
      min-width: 0;
      display: flex;
      justify-content: flex-end;
      align-items: flex-end;
      gap: 0.65rem;
      flex-wrap: wrap;
    }

    .panel-card-body {
      padding: 0.8rem 0.95rem 0.95rem 0.95rem;
      background: #fff;
      min-width: 0;
    }

    .control-inline {
      min-width: min(100%, 220px);
      flex: 1 1 220px;
    }

    .control-inline .shiny-input-container,
    .control-action .shiny-input-container {
      margin-bottom: 0 !important;
      min-width: 0;
    }

    .control-inline .bootstrap-select,
    .panel-header-controls .bootstrap-select,
    .panel-header-controls .shiny-input-container {
      width: 100% !important;
      min-width: 0 !important;
      margin-bottom: 0 !important;
    }

    .control-inline .shiny-input-container > label,
    .control-inline .form-label {
      font-size: 0.78rem;
      font-weight: 750;
      color: var(--dde-muted);
      margin-bottom: 0.3rem;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }

    .control-inline .bootstrap-select > .dropdown-toggle {
      min-height: var(--dde-control-height-sm);
      border-radius: 10px;
      background: #fff;
      font-size: 0.92rem;
    }

    .control-action {
      flex: 0 1 auto;
      min-width: 0;
      display: flex;
      align-items: flex-end;
    }

    .control-action .btn,
    #plot1Export.btn {
      min-height: var(--dde-control-height-sm);
    }

    #plot1Export.btn {
      background: var(--dde-blue);
      border-color: var(--dde-blue);
      color: #fff;
      padding-left: 1rem;
      padding-right: 1rem;
    }

    #plot1Export.btn:hover,
    #plot1Export.btn:focus {
      background: var(--dde-blue-dark);
      border-color: var(--dde-blue-dark);
      color: #fff;
    }

    .plot-shell {
      background: var(--dde-surface);
      border: 1px solid var(--dde-border);
      border-radius: 12px;
      padding: 0.65rem 0.75rem;
      min-width: 0;
    }

    .plot-shell .shiny-plot-output {
      height: clamp(320px, 55vh, 700px) !important;
    }

    .plot-caption {
      font-size: 0.84rem;
      color: var(--dde-muted);
      margin-top: 0.35rem;
      margin-bottom: 0;
      line-height: 1.3;
    }

    .table-shell {
      width: 100%;
      overflow-x: auto;
    }

    .recruitment-wrap {
      margin-bottom: 0.55rem;
      min-width: 0;
    }

    .recruitment-wrap .accordion-item {
      border: 1px solid var(--dde-border);
      border-left: 1px solid var(--dde-border);
      border-radius: 16px;
      overflow: hidden;
      box-shadow: var(--dde-shadow);
      background: var(--dde-surface);
      margin-bottom: 0;
      transition: all 0.18s ease;
    }

    .recruitment-wrap .accordion-item:hover {
      border-color: var(--dde-border-strong);
      border-left: 4px solid var(--dde-orange);
    }

    .recruitment-wrap .accordion-button {
      background: linear-gradient(135deg, #ffffff 0%, #fffaf2 100%);
      color: var(--dde-blue);
      font-weight: 750;
      padding: 0.72rem 0.9rem;
    }

    .recruitment-wrap .accordion-button:not(.collapsed) {
      background: linear-gradient(135deg, #ffffff 0%, #fff7ea 100%);
      color: var(--dde-blue);
      box-shadow: none;
    }

    .recruitment-wrap .accordion-body {
      padding: 0.5rem 0.75rem 0.65rem 0.75rem;
      background: #fffdf8;
      overflow-x: hidden;
    }

    .recruitment-note {
      color: var(--dde-muted);
      font-size: 0.88rem;
      margin-bottom: 0.35rem;
      line-height: 1.3;
    }

    .hires-shell {
      width: 100%;
      max-width: 100%;
      overflow: visible;
    }

    .hires-shell .datatables,
    .hires-shell .dataTables_wrapper {
      width: 100% !important;
      max-width: 100% !important;
      margin-bottom: 0 !important;
    }

    .hires-shell .dataTables_scroll {
      width: 100% !important;
    }

    .hires-shell .dataTables_scrollHead {
      margin-bottom: 0 !important;
    }

    .hires-shell .dataTables_scrollBody {
      border-bottom: 1px solid #d8e2ec;
      border-radius: 0 0 12px 12px;
    }

    .hires-shell table.dataTable {
      border-collapse: separate !important;
      border-spacing: 0;
      font-size: 13px;
      margin: 0 !important;
    }

    .hires-shell table.dataTable thead th {
      background: #f7fafc !important;
      color: #194a78 !important;
      font-weight: 700;
      border-bottom: 1px solid #d8e2ec !important;
      white-space: nowrap;
    }

    .hires-shell table.dataTable tbody td {
      border-bottom: 1px solid #eef2f7 !important;
      vertical-align: middle;
      white-space: nowrap;
    }

    .hires-shell .dtfc-fixed-left {
      background-color: #fcfdff !important;
    }

    .hires-shell .dataTables_scrollHead,
    .hires-shell .dataTables_scrollBody {
      border-left: 1px solid #d8e2ec;
      border-right: 1px solid #d8e2ec;
    }

    .hires-shell .dataTables_scrollHead {
      border-top: 1px solid #d8e2ec;
    }

    .hires-shell .dataTables_info,
    .hires-shell .dataTables_paginate,
    .hires-shell .dataTables_length,
    .hires-shell .dataTables_filter {
      margin: 0 !important;
      padding: 0 !important;
    }

    .data-download-shell {
      border: 1px solid var(--dde-border);
      border-radius: 12px;
      background: #fff;
      overflow: hidden;
    }

    .data-download-shell .dataTables_wrapper {
      padding: 0.75rem;
    }

    .data-download-shell .dataTables_filter {
      margin-bottom: 0.75rem !important;
    }

    .data-download-shell .dataTables_length,
    .data-download-shell .dataTables_filter {
      color: var(--dde-muted);
      font-size: 0.9rem;
    }

    .data-download-shell .dataTables_filter input,
    .data-download-shell .dataTables_length select {
      border: 1px solid var(--dde-border);
      border-radius: 10px;
      min-height: 38px;
      padding: 0.35rem 0.65rem;
      background: #fff;
      color: var(--dde-text);
    }

    .data-download-shell .dataTables_filter input:focus,
    .data-download-shell .dataTables_length select:focus {
      border-color: var(--dde-blue);
      box-shadow: var(--dde-focus-ring);
      outline: none;
    }

    .data-download-shell .dataTables_wrapper .dt-buttons {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
      margin-bottom: 0.75rem;
    }

    .data-download-shell .dataTables_wrapper .dt-button,
    .data-download-shell .dataTables_wrapper .buttons-excel,
    .data-download-shell .dataTables_wrapper .buttons-csv,
    .data-download-shell .dataTables_wrapper .buttons-copy {
      background: var(--dde-surface) !important;
      color: var(--dde-blue) !important;
      border: 1px solid var(--dde-border) !important;
      border-radius: 10px !important;
      min-height: var(--dde-control-height-sm);
      padding: 0.5rem 0.9rem !important;
      font-weight: 700 !important;
      font-size: 0.92rem !important;
      line-height: 1.2 !important;
      box-shadow: none !important;
      transition: all 0.18s ease !important;
      margin: 0 !important;
      background-image: none !important;
    }

    .data-download-shell .dataTables_wrapper .dt-button:hover,
    .data-download-shell .dataTables_wrapper .buttons-excel:hover,
    .data-download-shell .dataTables_wrapper .buttons-csv:hover,
    .data-download-shell .dataTables_wrapper .buttons-copy:hover {
      background: var(--dde-orange-soft) !important;
      color: var(--dde-blue) !important;
      border-color: var(--dde-orange) !important;
    }

    .data-download-shell .dataTables_wrapper .dt-button:focus,
    .data-download-shell .dataTables_wrapper .buttons-excel:focus,
    .data-download-shell .dataTables_wrapper .buttons-csv:focus,
    .data-download-shell .dataTables_wrapper .buttons-copy:focus {
      background: #fff !important;
      color: var(--dde-blue) !important;
      border-color: var(--dde-blue) !important;
      box-shadow: var(--dde-focus-ring) !important;
      outline: none !important;
    }

    .data-download-shell .dataTables_wrapper .dt-button:active,
    .data-download-shell .dataTables_wrapper .dt-button.active {
      background: #f4f8fc !important;
      color: var(--dde-blue) !important;
      border-color: var(--dde-blue) !important;
    }

    .data-download-shell .dataTables_wrapper .buttons-excel {
      background: var(--dde-blue) !important;
      color: #fff !important;
      border-color: var(--dde-blue) !important;
    }

    .data-download-shell .dataTables_wrapper .buttons-excel:hover,
    .data-download-shell .dataTables_wrapper .buttons-excel:focus {
      background: var(--dde-blue-dark) !important;
      color: #fff !important;
      border-color: var(--dde-blue-dark) !important;
    }

    @media (max-width: 1200px) {
      .bslib-sidebar-layout > .sidebar {
        min-width: 240px;
        max-width: 420px;
      }
    }

    @media (max-width: 992px) {
      .bslib-sidebar-layout > .sidebar {
        padding: 0.8rem 0.85rem 0.9rem 0.85rem;
        min-width: 100%;
        max-width: 100%;
      }

      .panel-header {
        flex-direction: column;
        align-items: stretch;
      }

      .panel-header-text,
      .panel-header-controls {
        width: 100%;
        flex: 1 1 100%;
      }

      .panel-header-controls {
        justify-content: flex-start;
      }

      .control-inline,
      .control-action {
        width: 100%;
        min-width: 0;
        flex: 1 1 100%;
      }

      .control-action .btn,
      #plot1Export.btn {
        width: 100%;
      }
    }

    @media (max-width: 768px) {
      .bootstrap-select > .dropdown-toggle,
      .form-control,
      .form-select,
      input[type='number'],
      .input-group > .form-control,
      .input-group > input[type='number'] {
        min-height: 42px;
        font-size: 0.93rem;
      }

      .tab-pane {
        padding: 0.55rem 0.6rem 0.65rem 0.6rem;
      }

      .panel-card-header,
      .panel-card-body {
        padding-left: 0.75rem;
        padding-right: 0.75rem;
      }

      .recruitment-wrap .accordion-button,
      .recruitment-wrap .accordion-body {
        padding-left: 0.75rem;
        padding-right: 0.75rem;
      }

      .plot-shell {
        padding: 0.55rem 0.6rem;
      }
    }

    @media (max-width: 576px) {
      .panel-card-header,
      .panel-card-body,
      .tab-pane {
        padding-left: 0.6rem;
        padding-right: 0.6rem;
      }

      .panel-title {
        line-height: 1.15;
      }
    }
  ")),
  
  sidebar = sidebar(
    width = 375,
    gap = "1rem",
    open = "always",
    
    title = div(
      class = "brand-wrap",
      img(src = "Website-Header.png", class = "brand-logo"),
      div(class = "brand-caption", "Teacher Workforce Planning Tool"),
      div(class = "brand-subcaption", "Delaware teacher workforce forecasting")
    ),
    
    div(
      class = "sidebar-section",
      div(class = "section-kicker", "Steps 1–2"),
      div(class = "section-title", "Select Scope and Forecast Year"),
      
      div(
        class = "info-callout",
        HTML("<strong>Use with care.</strong> TWPT provides planning estimates based on historical data and selected assumptions. Results should be interpreted alongside local context, policy changes, and workforce conditions.")
      ),
      
      div(
        class = "control-block",
        title = "Select an LEA, county, or statewide view for the forecast.",
        pickerInput(
          inputId = "LEA",
          label = "LEA or Grouping",
          choices = leaList,
          selected = "All LEAs",
          multiple = FALSE,
          options = pickerOptions(
            `actions-box` = FALSE,
            liveSearch = TRUE,
            size = 10
          )
        )
      ),
      
      div(
        class = "control-block",
        title = "Select the school year to which the forecast will extend.",
        pickerInput(
          inputId = "SchoolYear",
          label = "Projected School Year",
          choices = schoolYears,
          selected = paste0(yr - 1, "-", yr - 2000),
          multiple = FALSE,
          options = pickerOptions(
            `actions-box` = FALSE,
            size = 8
          )
        )
      )
    ),
    
    div(
      class = "sidebar-section",
      div(class = "section-kicker", "Steps 3–5"),
      div(class = "section-title", "Set Planning Targets"),
      
      accordion(
        open = FALSE,
        
        accordion_panel(
          title = "Enrollment & Student Need",
          value = "enrollment_student_need",
          
          div(
            class = "target-group",
            div(class = "subsection-title", "Enrollment and service need assumptions"),
            
            div(
              class = "control-block",
              title = "What percentage of the school-age population (ages 5–18) is expected to enroll in public schools?",
              numericInputIcon(
                inputId = "Mat",
                label = "Matriculation Rate",
                value = dfltVls$`Matriculation Rate`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("percent")
              ),
              p(
                class = "control-note",
                "Share of the school-age population expected to enroll in public schools."
              )
            ),
            
            div(
              class = "control-block",
              title = "What percentage of enrolled students is expected to receive special education services?",
              numericInputIcon(
                inputId = "IEP",
                label = "IEP Identification Rate",
                value = dfltVls$`IEP Identification Rate`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("percent")
              ),
              p(
                class = "control-note",
                "Share of enrolled students expected to receive special education services."
              )
            )
          )
        ),
        
        accordion_panel(
          title = "Teacher Demand",
          value = "teacher_demand",
          
          div(
            class = "target-group",
            div(class = "subsection-title", "Staffing intensity assumptions"),
            
            div(
              class = "control-block",
              title = "Average number of students with an IEP per full-time special education teacher.",
              numericInputIcon(
                inputId = "STsped",
                label = "Students per Teacher (Special Education)",
                value = dfltVls$`Students per Teacher (SPED)`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("users")
              ),
              p(
                class = "control-note",
                "Used to estimate special education teacher demand."
              )
            ),
            
            div(
              class = "control-block",
              title = "Average number of students without an IEP per full-time non-special education teacher.",
              numericInputIcon(
                inputId = "STgen",
                label = "Students per Teacher (Non-Special Education)",
                value = dfltVls$`Students per Teacher (Non-SPED)`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("users")
              ),
              p(
                class = "control-note",
                "Used to estimate non-special education teacher demand."
              )
            )
          )
        ),
        
        accordion_panel(
          title = "Teacher Retention",
          value = "teacher_retention",
          
          div(
            class = "target-group",
            div(class = "subsection-title", "Workforce stability assumptions"),
            
            div(
              class = "control-block",
              title = "What percentage of special education teachers typically return the following year?",
              numericInputIcon(
                inputId = "RRsped",
                label = "Teacher Retention Rate (Special Education)",
                value = dfltVls$`Teacher Retention Rate (SPED)`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("rotate-left")
              ),
              p(
                class = "control-note",
                "Applied to prior-year demand to estimate retained special education teachers."
              )
            ),
            
            div(
              class = "control-block",
              title = "What percentage of non-special education teachers typically return the following year?",
              numericInputIcon(
                inputId = "RRgen",
                label = "Teacher Retention Rate (Non-Special Education)",
                value = dfltVls$`Teacher Retention Rate (Non-SPED)`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("rotate-left")
              ),
              p(
                class = "control-note",
                "Applied to prior-year demand to estimate retained non-special education teachers."
              )
            )
          )
        )
      )
    ),
    
    div(
      class = "sidebar-footer",
      tags$a(
        href = "mailto:Matthew.Faiello@doe.k12.de.us?subject=TWPT%20Feedback&body=Your%20feedback%20goes%20directly%20to%20Matt%20Faiello%20%28he%2Fhim%29%2C%20Associate%20Data%20Scientist%20%40%20DDOE%20Data%20Analytics.",
        style = "text-decoration: none;",
        actionButton(
          inputId = "email1",
          label = "Have a Question or Suggestion?",
          icon = icon("envelope", lib = "font-awesome")
        )
      )
    )
  ),
  
  div(
    class = "main-stack",
    
    navset_card_underline(
      full_screen = TRUE,
      
      nav_panel(
        title = strong("Forecasts"),
        icon = icon("chart-line"),
        
        div(
          class = "panel-shell",
          
          div(
            class = "panel-card",
            
            div(
              class = "panel-card-header",
              div(
                class = "panel-header",
                div(
                  class = "panel-header-text",
                  div(class = "panel-title", "Projected Teacher Workforce"),
                  p(
                    class = "panel-subtitle",
                    "Compare projected teacher demand, retained teachers, and hiring need based on the selected planning targets."
                  )
                ),
                div(
                  class = "panel-header-controls",
                  div(
                    class = "control-inline",
                    title = "Choose the workforce measure you would like to visualize.",
                    pickerInput(
                      inputId = "PLT",
                      label = "Projected Measure",
                      choices = outputList,
                      selected = "Hiring Need (Total)",
                      multiple = FALSE,
                      options = pickerOptions(
                        `actions-box` = FALSE,
                        size = 10
                      )
                    )
                  ),
                  div(
                    class = "control-action",
                    title = "Download the current forecast chart and the planning target values used to produce it as a ZIP file.",
                    downloadButton(
                      outputId = "plot1Export",
                      label = "Download Forecast",
                      icon = icon("chart-line")
                    )
                  )
                )
              )
            ),
            
            div(
              class = "panel-card-body",
              
              div(
                class = "recruitment-wrap",
                accordion(
                  open = FALSE,
                  accordion_panel(
                    title = "Past Recruitment Numbers",
                    value = "past_recruitment_numbers",
                    icon = bs_icon("people", size = "1.1em"),
                    p(
                      class = "recruitment-note",
                      "Historical recruitment counts for the selected scope, including new hires, transfer hires, and total hires."
                    ),
                    div(
                      class = "hires-shell",
                      DTOutput("hires"),
                      p(
                        class = "recruitment-note",
                        "New hires are teachers not employed in a Delaware public school in the prior year. Transfer hires are teachers who moved between LEAs or between special education and non-special education roles."
                      )
                    )
                  )
                )
              ),
              
              div(
                class = "plot-shell",
                withSpinner(
                  plotOutput("plot", width = "100%", height = "100%"),
                  size = getOption("spinner.size", default = 3),
                  color = getOption("spinner.color", default = "#194a78")
                ),
                p(
                  class = "plot-caption",
                  "Forecasts reflect the selected scope and planning targets and should be interpreted as planning estimates rather than exact predictions."
                )
              )
            )
          )
        )
      ),
      
      nav_panel(
        title = strong("Planning Target Trends"),
        icon = icon("crosshairs"),
        
        div(
          class = "panel-shell",
          div(
            class = "panel-card",
            div(
              class = "panel-card-header",
              div(
                class = "panel-header",
                div(
                  class = "panel-header-text",
                  div(class = "panel-title", "Planning Target Trends"),
                  p(
                    class = "panel-subtitle",
                    "View historical and projected trends in key planning targets to help set future assumptions."
                  )
                ),
                div(
                  class = "panel-header-controls",
                  div(
                    class = "control-inline",
                    title = "Choose the planning target you would like to explore.",
                    pickerInput(
                      inputId = "MTRC",
                      label = "Planning Target",
                      choices = metricList,
                      selected = "Matriculation Rate",
                      multiple = FALSE,
                      options = pickerOptions(
                        `actions-box` = FALSE,
                        size = 10
                      )
                    )
                  )
                )
              )
            ),
            div(
              class = "panel-card-body",
              div(
                class = "plot-shell",
                withSpinner(
                  plotOutput("metric", width = "100%", height = "100%"),
                  size = getOption("spinner.size", default = 2),
                  color = getOption("spinner.color", default = "#194a78")
                ),
                p(
                  class = "plot-caption",
                  "Trend views provide historical context and projected values for the planning targets used in forecasting."
                )
              )
            )
          )
        )
      ),
      
      nav_panel(
        title = strong("Data Download"),
        icon = icon("table"),
        
        div(
          class = "panel-shell",
          div(
            class = "panel-card",
            div(
              class = "panel-card-header",
              div(
                class = "panel-header",
                div(
                  class = "panel-header-text",
                  div(class = "panel-title", "Underlying Data"),
                  p(
                    class = "panel-subtitle",
                    "Review and export the historical and forecasted values underlying the planning views and workforce forecasts."
                  )
                )
              )
            ),
            div(
              class = "panel-card-body",
              div(
                class = "data-download-shell",
                div(
                  class = "table-shell",
                  DTOutput("hist")
                )
              )
            )
          )
        )
      )
    )
  )
)
