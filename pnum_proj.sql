select branches.project, count(*) as "number of changes", avg(current_patch_sets.number) as "avarage number of iterations",
       strftime("%j", avg(master_changes.closed_at - master_changes.created_on), 'unixepoch') as "avarage review duration (days)"
from master_changes inner join branches on master_changes.branch_id = branches.branch_id inner join (
    select change_num, max(number) as number from patch_sets group by change_num
) as current_patch_sets on current_patch_sets.change_num = master_changes.number
where master_changes.status = "MERGED" and datetime(master_changes.closed_at, 'unixepoch') between :start and :end
group by branches.project
order by "avarage number of iterations"
