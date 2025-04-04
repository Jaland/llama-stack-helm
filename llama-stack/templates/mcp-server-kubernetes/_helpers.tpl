{{/*
Expand the name of the chart.
*/}}
{{- define "mcp-server-kube.name" -}}
{{- printf "%s-%s" (default .Chart.Name .Values.nameOverride | trunc 51  | trimSuffix "-") "mcp-kubernetes" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mcp-server-kube.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- print (default .Chart.Name .Values.fullNameOverride | trunc 51  | trimSuffix "-") "-mcp-kubernetes" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- print (.Release.Name | trunc 51  | trimSuffix "-") "-mcp-kubernetes" }}
{{- else }}
{{- print (printf "%s-%s" .Release.Name $name | trunc 51 | trimSuffix "-") "-mcp-kubernetes" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mcp-server-kube.labels" -}}
helm.sh/chart: {{ include "llama-stack.chart" . }}
{{ include "mcp-server-kube.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
mcp Selector labels
*/}}
{{- define "mcp-server-kube.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mcp-server-kube.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
