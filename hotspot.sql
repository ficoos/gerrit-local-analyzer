select file, count(*) as "commit count"
from patch_set_files inner join (
    select revision
    from patch_sets inner join (
        select patch_sets.change_num, max(patch_sets.number) as number
         from (
             select master_changes.number
             from master_changes inner join branches on master_changes.branch_id = branches.branch_id
             where status="MERGED" and datetime(closed_at, 'unixepoch') between :start and :end and branches.project = :project
         ) as open_changes inner join patch_sets on open_changes.number = patch_sets.change_num
         group by patch_sets.change_num
    ) as current_patchsets on current_patchsets.change_num = patch_sets.change_num and current_patchsets.number = patch_sets.number
) as merged_revisions on merged_revisions.revision = patch_set_files.patch_set_id
where file != "/COMMIT_MSG"
group by file
order by "commit count" desc

