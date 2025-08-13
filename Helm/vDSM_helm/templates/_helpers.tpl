{{/*
Expand the name of the chart.
*/}}
{{- define "vdsm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vdsm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vdsm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vdsm.labels" -}}
helm.sh/chart: {{ include "vdsm.chart" . }}
{{ include "vdsm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vdsm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vdsm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vdsm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vdsm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the config map to use
*/}}
{{- define "vdsm.configMapName" -}}
{{- if .Values.configMap.enabled }}
{{- include "vdsm.fullname" . }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "vdsm.secretName" -}}
{{- if .Values.secret.enabled }}
{{- include "vdsm.fullname" . }}
{{- end }}
{{- end }}

{{/*
Create the name of the PVC to use
*/}}
{{- define "vdsm.pvcName" -}}
{{- if .Values.persistence.enabled }}
{{- printf "%s-pvc" (include "vdsm.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name of the PV to use
*/}}
{{- define "vdsm.pvName" -}}
{{- if and .Values.persistence.enabled .Values.nfs.enabled }}
{{- printf "%s-pv" (include "vdsm.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the name of the StorageClass to use
*/}}
{{- define "vdsm.storageClassName" -}}
{{- if .Values.nfs.storageClass.create }}
{{- .Values.nfs.storageClass.name }}
{{- end }}
{{- end }}
