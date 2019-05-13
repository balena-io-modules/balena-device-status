/*
Copyright 2016 Balena

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import { status } from './index';

export type StatusKey = typeof status[keyof typeof status];

export interface Status {
	key: StatusKey;
	name: string;
}

export interface IHaveProgressAndStatus {
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
