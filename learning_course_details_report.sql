/*
===============================================================================
File Name  : learning_course_details_report.sql
Module     : Oracle Fusion HCM - Learning
Description: 
This report extracts course assignment, enrollment, and completion details
from Oracle Learning Cloud along with employee, manager, and organization data.

Author     : Madhukar
Created    : 2026
===============================================================================
*/

SELECT
    course_dtl.person_number,
    course_dtl.full_name,
    course_dtl.first_name,
    course_dtl.last_name,
    course_dtl.email_address,
    course_dtl.legal_employer,
    course_dtl.bu_name,
    course_dtl.job,
    course_dtl.job_function,
    course_dtl.contributor_type,
    course_dtl.job_family,
    course_dtl.assignment_name,
    course_dtl.business_group,
    course_dtl.platform,
    course_dtl.country_name,
    course_dtl.location_name,
    course_dtl.location_id,
    course_dtl.department_name,
    course_dtl.course_learning_item_id,
    course_dtl.course_number,
    course_dtl.course_name,
    course_dtl.course_status_code,
    course_dtl.reason_code,
    course_dtl.reason,
    course_dtl.course_status,
    course_dtl.direct_line_mgr_id,
    course_dtl.direct_line_mgr,
    course_dtl.matrix_mngr_id,
    course_dtl.matrix_mngr,
    course_dtl.assignment_record_number,
    course_dtl.expiration_date,
    course_dtl.completion_date,
    course_dtl.calculated_due_date,
    course_dtl.learning_item_id,
    course_dtl.event_type,
    course_dtl.assignment_type,
    course_dtl.assigned_on_date,
    course_dtl.total_actual_effort,
    course_dtl.learning_item_type,
    course_dtl.enrolled_by,
    course_dtl.world_area,
    course_dtl.status_change_comment

FROM
(
    SELECT
        papf.person_number,
        papf.person_id,
        ppnf.full_name,
        ppnf.first_name,
        ppnf.last_name,
        peaw.email_address,
        haoufvl_le.name legal_employer,
        fabuv.bu_name,
        pj.name job,

        PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP(
            'JOB_FUNCTION_CODE',
            pj.job_function_code
        ) job_function,

        PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP(
            'MANAGER_LEVEL',
            pj.manager_level
        ) contributor_type,

        job_family.job_family_name job_family,
        paam.assignment_name,
        org_udt.business_group,
        org_udt.platform,
        country.geography_name country_name,
        loc.location_name,
        paam.location_id,
        pd.name department_name,

        course.learning_item_id course_learning_item_id,
        course.learning_item_number course_number,
        coursetl.name course_name,

        wlfarf_course.sub_status course_status_code,
        wlfarf_course.reason_code,

        PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP(
            'ORA_WLF_ASSIGN_RECORD_STATUS',
            wlfarf_course.sub_status
        ) course_status,

        wlfarf_course.assignment_record_number,
        wlfarf_course.expiration_date,
        wlfarf_course.completion_date,
        wlfarf_course.calculated_due_date,

        TO_CHAR(wlfarf_course.learning_item_id) learning_item_id,
        wlfarf_course.event_type,

        PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP(
            'ORA_WLF_ASSIGN_REC_TYPE',
            wlfarf_course.event_type
        ) assignment_type,

        wlfarf_course.assigned_on_date,
        wlfarf_course.total_actual_effort,

        PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP(
            'ORA_WLF_LEARNING_ITEM_TYPE',
            wlfarf_course.learning_item_type
        ) learning_item_type,

        wlfarf_course.status_change_comment,

        ppnf.display_name enrolled_by,

        org_udt.business_group,
        org_udt.platform,

        country.geography_name world_area,

        /* Manager */

        (
            SELECT pp.person_number
            FROM per_all_people_f pp,
                 per_assignment_supervisors_f pas
            WHERE pas.assignment_id = paam.assignment_id
            AND pas.manager_type = 'LINE_MANAGER'
            AND pas.manager_id = pp.person_id
            AND TRUNC(SYSDATE)
                BETWEEN pp.effective_start_date
                AND pp.effective_end_date
        ) direct_line_mgr_id,

        (
            SELECT pn.full_name
            FROM per_person_names_f pn,
                 per_assignment_supervisors_f pas
            WHERE pas.assignment_id = paam.assignment_id
            AND pas.manager_type = 'LINE_MANAGER'
            AND pas.manager_id = pn.person_id
            AND pn.name_type = 'GLOBAL'
            AND TRUNC(SYSDATE)
                BETWEEN pn.effective_start_date
                AND pn.effective_end_date
        ) direct_line_mgr,

        (
            SELECT LISTAGG(pp.person_number, ', ')
                   WITHIN GROUP (ORDER BY pp.person_number)
            FROM per_all_people_f pp,
                 per_assignment_supervisors_f pas
            WHERE pas.assignment_id = paam.assignment_id
            AND pas.manager_type = 'FUNC_REPORT'
            AND pas.manager_id = pp.person_id
        ) matrix_mngr_id,

        (
            SELECT LISTAGG(pn.full_name, ', ')
                   WITHIN GROUP (ORDER BY pn.full_name)
            FROM per_person_names_f pn,
                 per_assignment_supervisors_f pas
            WHERE pas.assignment_id = paam.assignment_id
            AND pas.manager_type = 'FUNC_REPORT'
            AND pas.manager_id = pn.person_id
            AND pn.name_type = 'GLOBAL'
        ) matrix_mngr

    FROM
        wlf_learning_items_f course,
        wlf_learning_items_f_tl coursetl,
        wlf_assignment_records_f wlfarf_course,
        per_all_people_f papf,
        per_all_assignments_m paam,
        per_person_names_f ppnf,
        per_email_addresses peaw,
        fun_all_business_units_v fabuv,
        hr_all_organization_units_f_vl haoufvl_le,
        per_jobs_f_vl pj,
        per_job_family_f_vl job_family,
        per_location_details_f_vl loc,
        hz_geographies country,
        per_departments pd,
        (
            SELECT
                fuci_plat.value platform,
                fuci_bg.value business_group,
                fur.row_name business_unit
            FROM ff_user_tables_vl fut,
                 ff_user_rows_vl fur,
                 ff_user_columns_vl fuc_plat,
                 ff_user_column_instances_f fuci_plat,
                 ff_user_columns_vl fuc_bg,
                 ff_user_column_instances_f fuci_bg
            WHERE fut.base_user_table_name =
                  'EMR_ORGANIZATION_STRUCTURE_UDT'
        ) org_udt

    WHERE 1 = 1
    AND course.learning_item_type = 'ORA_COURSE'
    AND course.learning_item_id = coursetl.learning_item_id
    AND course.learning_item_id = wlfarf_course.learning_item_id
    AND papf.person_id = wlfarf_course.learner_id
    AND papf.person_id = paam.person_id
    AND paam.assignment_type IN ('E','C')
    AND paam.location_id = loc.location_id
    AND paam.job_id = pj.job_id(+)
    AND pj.job_family_id = job_family.job_family_id(+)
    AND paam.organization_id = pd.organization_id
    AND paam.business_unit_id = fabuv.bu_id
    AND paam.legal_entity_id = haoufvl_le.organization_id(+)
    AND papf.person_id = ppnf.person_id
    AND papf.person_id = peaw.person_id(+)
    AND peaw.email_type(+) = 'W1'
    AND country.geography_type = 'COUNTRY'
) course_dtl

WHERE 1 = 1
AND (course_dtl.country_name IN (:pCountry)
     OR LEAST(:pCountry) IS NULL)

AND (course_dtl.legal_employer IN (:pLegalEmployer)
     OR LEAST(:pLegalEmployer) IS NULL)

AND (course_dtl.location_id IN (:pLocation)
     OR LEAST(:pLocation) IS NULL)

AND (course_dtl.course_name IN (:pLearningItemTitle)
     OR LEAST(:pLearningItemTitle) IS NULL)

AND (course_dtl.person_number IN (:pPersonNumber)
     OR LEAST(:pPersonNumber) IS NULL)

AND (course_dtl.person_id IN (:pPersonName)
     OR LEAST(:pPersonName) IS NULL)

AND (course_dtl.world_area IN (:WorldArea)
     OR LEAST(:WorldArea) IS NULL)

AND (course_dtl.business_group IN (:BusinessGroup)
     OR LEAST(:BusinessGroup) IS NULL);
