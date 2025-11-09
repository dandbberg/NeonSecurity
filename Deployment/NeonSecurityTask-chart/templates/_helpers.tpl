{{- define "NeonSecurityTask-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | lower | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "NeonSecurityTask-chart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | lower | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | lower | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | lower | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "NeonSecurityTask-chart.labels" -}}
helm.sh/chart: {{ include "NeonSecurityTask-chart.chart" . }}
app.kubernetes.io/name: {{ include "NeonSecurityTask-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "NeonSecurityTask-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "NeonSecurityTask-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "NeonSecurityTask-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "NeonSecurityTask-chart.fullname" .) .Values.serviceAccount.name | lower -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name | lower -}}
{{- end -}}
{{- end -}}

{{- define "NeonSecurityTask-chart.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

