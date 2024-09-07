SELECT
	a.ID AS chievoId,
	a.Title_lang,
	a.Description_lang,
	a.Ui_order,
	m.ExpansionID,
	g.GroupFinderActivityGrpID AS activityGroupId,
	m.MapName_lang AS mapName,
	case
		when a.Description_lang = 'Defeat the following bosses on any difficulty.' then '1 normal'
		when a.Title_lang LIKE 'Ahead of the Curve: %' then '2 curve'
		when a.Title_lang LIKE 'Cutting Edge: %' then '3 edge'
		when (a.Description_lang LIKE 'Defeat % in % on Mythic difficulty.' AND a.Title_lang LIKE 'Mythic: %') then '4 mythic'
	END AS note,
	case
		when a.Description_lang = 'Defeat the following bosses on any difficulty.' then CONCAT('normal = ', a.ID, ',')
		when a.Title_lang LIKE 'Ahead of the Curve: %' then CONCAT('curve = ', a.ID, ',')
		when a.Title_lang LIKE 'Cutting Edge: %' then CONCAT('edge = ', a.ID, ',')
		when (a.Description_lang LIKE 'Defeat % in % on Mythic difficulty.' AND a.Title_lang LIKE 'Mythic: %') then CONCAT(a.ID, ', --', SUBSTR(a.Title_lang, LENGTH('Mythic: ')))
	END AS copyable
FROM Achievement a
JOIN Map m ON (a.Instance_ID = m.ID OR a.Title_lang = m.MapName_lang OR a.Description_lang LIKE CONCAT('%', m.MapName_lang, '%'))
JOIN GroupFinderActivity g ON g.MapID = m.ID

WHERE
    g.GroupFinderCategoryID = 3
	AND m.InstanceType = 2
	AND m.ExpansionID > 5

GROUP BY a.ID
HAVING note IS NOT NULL
ORDER BY g.GroupFinderActivityGrpID DESC, note, a.Ui_order
