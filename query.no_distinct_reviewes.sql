SELECT 	accounts.name,
        case when changes_opened then changes_opened else 0 end as "changes opened",
       	changes_opened_ids as "changes opened (IDs)",
	case when changes_abandoned then changes_abandoned else 0 end as "changes abandoned",
	changes_abandoned_ids as "changes abandoned (IDs)",
	case when changes_merged then changes_merged else 0 end as "changes merged",
	changes_merged_ids as "changes merged (IDs)",
	case when messages_posted then messages_posted else 0 end as "messages posted",
	case when comments_written then comments_written else 0 end as "comments written",
	case when changes_reviewed then changes_reviewed else 0 end as "changes reviewed",
	changes_reviewed_ids as "changes reviewed (IDs)",
	case when plus_ones then plus_ones else 0 end as "CR+1",
	case when plus_twos then plus_twos else 0 end as "CR+2",
	case when minus_ones then minus_ones else 0 end as "CR-1",
	case when minus_twos then minus_twos else 0 end as "CR-2"
FROM emails INNER JOIN accounts ON emails.username = accounts.username INNER JOIN
	(SELECT owner,
		count(case when datetime(master_changes.created_on, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end) then 1 end) AS changes_opened,
	        count(case when datetime(master_changes.closed_at, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end) AND status = "ABANDONED" then 1 end) AS changes_abandoned,
	        count(case when datetime(master_changes.closed_at, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end) AND status = "MERGED" then 1 end) AS changes_merged,
		group_concat(case when datetime(master_changes.created_on, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end) then number end) AS changes_opened_ids,
	        group_concat(case when datetime(master_changes.closed_at, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end) AND status = "ABANDONED" then number end) AS changes_abandoned_ids,
	        group_concat(case when datetime(master_changes.closed_at, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end) AND status = "MERGED" then number end) AS changes_merged_ids
	 FROM master_changes
	 WHERE datetime(master_changes.created_on, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end) OR
	       datetime(master_changes.closed_at, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end)
	 GROUP BY owner) AS changes_stats ON changes_stats.owner = emails.email
	LEFT OUTER JOIN
	(SELECT reviewer, count(*) AS messages_posted, sum(comment_num) AS comments_written,
		group_concat(DISTINCT case when reviewer != master_changes.owner then messages.change_num end) as changes_reviewed_ids,
		count(DISTINCT case when reviewer != master_changes.owner then messages.change_num end) as changes_reviewed
	 FROM messages INNER JOIN master_changes on messages.change_num = master_changes.number
	 WHERE datetime(timestamp, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end)
	 GROUP BY reviewer) AS messagesPosted ON messagesPosted.reviewer = emails.email
	LEFT OUTER JOIN
	(SELECT reviewer, count(case when label_value = "+1" then 1 end) AS plus_ones,
		          count(case when label_value = "+2" then 1 end) AS plus_twos,
		          count(case when label_value = "-1" then 1 end) AS minus_ones,
		          count(case when label_value = "-2" then 1 end) AS minus_twos
	 FROM messages INNER JOIN labels ON messages.message_id = labels.message_id
	 WHERE label_name = "Code-Review" AND
	       datetime(timestamp, 'unixepoch') BETWEEN datetime(:start) AND datetime(:end)
	 GROUP BY reviewer) labelSummery ON labelSummery.reviewer = emails.email
