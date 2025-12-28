SHOW PROCEDURE STATUS LIKE 'ACSBV3_proc_smooth_curve';


CALL ACSBV3_proc_smooth_curve(
  'ACSBV3_doc_item_template',
  'ACSBV3_ref_curve_equipment_final',
  'Equipment'
);

SELECT * FROM ACSBV3_ref_curve_equipment_final
ORDER BY Quality, expansion, ItemLevel
LIMIT 20;


CALL ACSBV3_proc_smooth_curve(
  'ACSBV3_doc_item_template',
  'ACSBV3_ref_curve_weapons_final',
  'Weapon'
);

SELECT * FROM ACSBV3_ref_curve_weapons_final
ORDER BY Quality, expansion, ItemLevel
LIMIT 20;
