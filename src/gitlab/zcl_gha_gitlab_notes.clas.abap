CLASS zcl_gha_gitlab_notes DEFINITION
  PUBLIC
  CREATE PROTECTED
  GLOBAL FRIENDS zcl_gha_gitlab_factory .

  PUBLIC SECTION.

    INTERFACES zif_gha_gitlab_notes .

    METHODS constructor
      IMPORTING
        !iv_project_id TYPE i .
  PROTECTED SECTION.

    DATA mv_project_id TYPE i .

    METHODS parse
      IMPORTING
        !iv_json       TYPE string
      RETURNING
        VALUE(rt_list) TYPE zif_gha_gitlab_notes=>ty_list_tt .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITLAB_NOTES IMPLEMENTATION.


  METHOD constructor.

    mv_project_id = iv_project_id.

  ENDMETHOD.


  METHOD parse.

    DATA(lo_json) = NEW zcl_gha_json_parser( iv_json ).

    LOOP AT lo_json->members( '' ) INTO DATA(lv_member) WHERE NOT table_line IS INITIAL.
      APPEND VALUE #(
        id   = lo_json->value_integer( |/{ lv_member }/id| )
        body = lo_json->value( |/{ lv_member }/body| )
        ) TO rt_list.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_gha_gitlab_notes~create_merge_request.

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://gitlab.com/api/v4/projects/{ mv_project_id }/merge_requests/{ iv_merge_request_iid }/notes| ).

    lo_client->set_method( 'POST' ).

    lo_client->set_header_field(
      iv_name  = 'content-type'
      iv_value = 'application/json' ).

    DATA(lv_json) = |\{"body": "{ iv_body }"\}\n|.

    lo_client->set_cdata( lv_json ).

    DATA(li_response) = lo_client->send_receive( ).

    li_response->get_status( IMPORTING code = DATA(lv_code) reason = DATA(lv_reason) ).
    DATA(lv_sdf) = li_response->get_cdata( ).
    ASSERT lv_code = 201. " todo, error handling

  ENDMETHOD.


  METHOD zif_gha_gitlab_notes~list_merge_request.

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://gitlab.com/api/v4/projects/{ mv_project_id }/merge_requests/{ iv_merge_request_iid }/notes| ).

    DATA(li_response) = lo_client->send_receive( ).

    DATA(lv_data) = li_response->get_cdata( ).

    li_response->get_status( IMPORTING code = DATA(lv_code) reason = DATA(lv_reason) ).
    ASSERT lv_code = 200. "  todo

    rt_list = parse( lv_data ).

  ENDMETHOD.
ENDCLASS.
