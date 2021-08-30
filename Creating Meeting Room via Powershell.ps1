$MeetingRoom=Get-Mailbox 'USMN-MintekHRandEvents'

Get-Mailbox $MeetingRoom | Set-CalendarProcessing -BookingWindowInDays 880

Set-MailboxFolderPermission -Identity ${MeetingRoom}:\Calendar -User Default -AccessRights LimitedDetails

Get-Mailbox $MeetingRoom | Set-MailboxCalendarConfiguration -WorkingHoursStartTime 00:00:00 -WorkingHoursEndTime 00:00:00

