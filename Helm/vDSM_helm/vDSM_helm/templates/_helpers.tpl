{{/*
Common labels for VDSM resources
*/}}
{{- define "vdsm.labels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Common annotations for VDSM resources
*/}}
{{- define "vdsm.annotations" -}}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations | nindent 4 }}
{{- end }}
{{- end -}}

{{/*
Generate the PVC name
*/}}
{{- define "vdsm.pvcName" -}}
{{ .Release.Name }}-vdsm-pvc
{{- end -}}