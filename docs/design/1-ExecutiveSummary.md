# Executive Summary

A feature of IT governance is auditing: recording who or what did something, what was done, and when it was done.  

Azure maintains an audit trail for each subscription in a feature called Activity Log. Activity Log retains the audit trail for just 90 days. Most organisations require an audit trail that can persist for years, but this must be accomplished at a low cost.

## Governance Logging

The purpose of the Governance Logging component is to provide a secure, scalable and economic system for the records in Activity Log. Once the records are stored in this component, based on Azure blob storage, the records can be retained for as long as the organisation wants (within the lifetime of Microsoft Azure) and subject to the retention limitations set out by the General Data Protection Regulation (GDPR).

The storage location is secure:

* It is placed into the Governance subscription (a part of the Innofactor Azure Cloud Foundation); few people should have access to this subscription.
* A resource lock will prevent accidental deletion of the storage.
* Once the retention period is agreed, a read-only policy will be applied to the storage, making it read-only and tamper-proof.
* Once the retention period is agreed, an automatic deletion policy will remove records that are 1 day past the retention period.

Each Azure subscription will generate 1 log per hour. The log will be retained in a read-only state for a pre-defined number of days (366 days per year). One day after the retention period, each log will be deleted. This will accomplish the purpose of Governance Logging – retaining logs in a temper-proof state for a long time. The records are not searchable or usable in a reporting system; however, they can be copied/exported to meet legal requirements.

*The Management Monitoring component will also collect this data and retain it for a fixed shorter amount of time. There, the data is in a more usable state for querying and reporting.*
