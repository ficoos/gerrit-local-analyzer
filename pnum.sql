select owner, count(*) as "number of changes", avg(current_patch_sets.number) as "avarage number of iterations",
       strftime("%j %H-%M-%S", avg(master_changes.closed_at - master_changes.created_on), 'unixepoch') as "avarage review duration"
from master_changes inner join branches on master_changes.branch_id = branches.branch_id inner join (
    select change_num, max(number) as number from patch_sets group by change_num
) as current_patch_sets on current_patch_sets.change_num = master_changes.number
where master_changes.closed_at > 0 and datetime(master_changes.closed_at, 'unixepoch') > datetime(:start) and datetime(master_changes.closed_at, 'unixepoch') < datetime(:end)
group by master_changes.owner
