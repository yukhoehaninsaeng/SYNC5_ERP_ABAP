*&---------------------------------------------------------------------*
*& Include SAPMZC302PP0005TOP                       - Module Pool      SAPMZC302PP0005
*&---------------------------------------------------------------------*
PROGRAM sapmzc302pp0005 MESSAGE-ID k5.



**********************************************************************
* Screen Elements
**********************************************************************
*-- 검색조건
*-- SCREEN 100
DATA : gv_PONUM2     TYPE zc302ppt0007-ponum,  " 생산오더에서 생산오더 번호 - 조회용
       gv_MATNR2     TYPE zc302mt0007-matnr,   " 자재마스터에서 자재코드 - 조회용
       gv_PLANT      TYPE zc302mt0004-plant,   " 공장마스터에서 공장코드
       gv_PPEND_low  TYPE zc302ppt0011-ppend,  " 생산오더별 공정진행로그 테이블에서 공정종료일
       gv_PPEND_high TYPE zc302ppt0011-ppend.  " 생산오더별 공정진행로그 끝 범위

*-- 라디오 버튼
DATA : gv_rb1    TYPE c,
       gv_rb2    TYPE c,
       gv_rb3    TYPE c,
       gv_rb4(1).


*-- 팝업스크린
*-- SCREEN 101
DATA : gv_ponum    TYPE zc302ppt0011-ponum,      " 101번 팝업에서 read only 받아오기용
       gv_matnr    TYPE zc302ppt0011-matnr,      " 101번 팝업에서 read only 받아오기용
       gv_rqamt    TYPE zc302ppt0007-rqamt,      " 생산오더에서 필요소요량 -> 만들기로 계획한 수량
       gv_menge    TYPE zc302ppt0012-menge,      " 생산실적처리에서 최종생산량
       gv_dismenge TYPE zc302ppt0011-dismenge,   " 검수 정보에서 폐기량 - 하드코딩
       gv_unit     TYPE zc302ppt0011-unit,       " 단위
       gv_qidat    TYPE zc302ppt0011-qidat,      " 검수 정보에서 검수일
       gv_emp_num  TYPE zc302mt0003-emp_num,     " 검수자(사원번호)
       gv_direason TYPE zc302ppt0011-direason.   " 폐기사유

**********************************************************************
* RANGES
**********************************************************************
RANGES : gr_ponum FOR zc302ppt0011-ponum,
         gr_matnr FOR zc302ppt0011-matnr,
         gr_plant FOR zc302ppt0011-plant,
         gr_ppend FOR zc302ppt0011-ppend.


**********************************************************************
* Class instance
**********************************************************************
DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.


DATA : go_pop_cont  TYPE REF TO cl_gui_custom_container, " popup
       "       go_pop_grid TYPE REF TO cl_gui_alv_grid.         " popup
       go_text_edit TYPE REF TO cl_gui_textedit.        " 텍스트에디터
" 팝업 컨테이너에 텍스트 에디터를 붙인다.

" 102
DATA : go_pop_cont2   TYPE REF TO cl_gui_custom_container,
       go_text_edit2  TYPE REF TO cl_gui_textedit.


**********************************************************************
* Work Area and Internal Table
**********************************************************************
" 조회했을 때 보여주기용 테이블
DATA : BEGIN OF gs_check,
         icon TYPE icon-id.
         INCLUDE STRUCTURE zc302ppt0011.
DATA : END OF gs_check,
gt_check LIKE TABLE OF gs_check.


" tdline만을 위한 인터널 테이블 - text editor에서 사용
DATA : BEGIN OF gs_content,
         tdline TYPE tdline,
       END OF gs_content,
       gt_content LIKE TABLE OF gs_content.


*-- 입고 버튼 눌렀을 때 발생하는 것들 위해
" 자재문서 Header
DATA: gt_md_header TYPE TABLE OF zc302mmt0011,
      gs_md_header TYPE zc302mmt0011.

" 자재문서 Item
DATA: gt_md_item TYPE TABLE OF zc302mmt0012,
      gs_md_item TYPE zc302mmt0012.

" 재고관리 테이블 header
DATA: gt_inv_h TYPE TABLE OF zc302mmt0013,      " inventory management
      gs_inv_h TYPE zc302mmt0013.

" 재고관리 테이블 item
DATA: gt_inv_i TYPE TABLE OF zc302mmt0002,
      gs_inv_i TYPE zc302mmt0002.

" 생산실적처리
DATA: gt_pro_per TYPE TABLE OF zc302ppt0012,
      gs_pro_per TYPE zc302ppt0012.

" 자재마스터
DATA: gt_mat TYPE TABLE OF zc302mt0007,
      gs_mat TYPE zc302mt0007.

" BOM
DATA: gt_bom TYPE TABLE OF zc302ppt0004,
      gs_bom TYPE zc302ppt0004.

" 공정 Header
DATA: gt_pcode TYPE TABLE OF zc302ppt0008,
      gs_pcode TYPE zc302ppt0008.

" 폐기 업데이트용
DATA: gt_dis TYPE TABLE OF ZC302MMT0001,
      gs_dis TYPE ZC302MMT0001.


*-- For ALV
DATA : gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gs_variant TYPE disvariant.

*-- For button
DATA : gs_button TYPE stb_button.     " 툴바 버튼

*-- For Popup
DATA : gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_t_fcat,
       gs_playout TYPE lvc_s_layo.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode TYPE sy-ucomm,
       gv_tabix  TYPE sy-tabix.
" 입고버튼 눌렀을 때
DATA : gv_rtptqua TYPE zc302mmt0013-h_rtptqua,
       gv_mblnr   TYPE zc302mmt0011-mblnr.

" 폐기번호 채번용
DATA : gv_year(6),
       gv_month(2),
       gv_day(2).
