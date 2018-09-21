declare module 'resin-device-status' {

	interface IHaveProgressAndStatus {
		download_progress?: number;
		status: string;
	}

	export interface Device extends IHaveProgressAndStatus {
		is_active: boolean;
		is_online: boolean;
		last_connectivity_event?: string;
		provisioning_progress?: number;
		provisioning_state: string;
		current_services?: {
			[serviceName: string]: IHaveProgressAndStatus[];
		};
	}

	export const status: {
		CONFIGURING: 'configuring';
		IDLE: 'idle';
		OFFLINE: 'offline';
		INACTIVE: 'inactive'
		POST_PROVISIONING: 'post-provisioning';
		UPDATING: 'updating';
	};

	type StatusKey = typeof status[keyof typeof status];

	interface Status {
		key: StatusKey;
		name: string;
	}

	export interface Statuses extends Array<Status> {}

	export function getStatus(device: Device): Status;

	export const statuses: Statuses;
}
