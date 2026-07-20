################################################################################
# Default Deny All Traffic
################################################################################

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/component: security
    app.kubernetes.io/part-of: banking-platform
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress

---

################################################################################
# Allow DNS Resolution
################################################################################

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: ingress-nginx
spec:

  podSelector: {}

  policyTypes:
    - Egress

  egress:

    - to:

        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system

          podSelector:
            matchLabels:
              k8s-app: kube-dns

      ports:

        - protocol: UDP
          port: 53

        - protocol: TCP
          port: 53

---

################################################################################
# Allow Controller Public Traffic
################################################################################

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-controller-public
  namespace: ingress-nginx

spec:

  podSelector:
    matchLabels:
      app.kubernetes.io/component: controller

  policyTypes:
    - Ingress

  ingress:

    - ports:

        - protocol: TCP
          port: 80

        - protocol: TCP
          port: 443

---

################################################################################
# Allow Prometheus Metrics
################################################################################

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus
  namespace: ingress-nginx

spec:

  podSelector:
    matchLabels:
      app.kubernetes.io/component: controller

  policyTypes:
    - Ingress

  ingress:

    - from:

        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring

      ports:

        - protocol: TCP
          port: 10254

---

################################################################################
# Admission Webhook
################################################################################

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admission-webhook

  namespace: ingress-nginx

spec:

  podSelector:
    matchLabels:
      app.kubernetes.io/component: controller

  policyTypes:
    - Ingress

  ingress:

    - ports:

        - protocol: TCP
          port: 8443

---

################################################################################
# Allow Controller -> Banking Applications
################################################################################

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: controller-egress

  namespace: ingress-nginx

spec:

  podSelector:
    matchLabels:
      app.kubernetes.io/component: controller

  policyTypes:
    - Egress

  egress:

    - to:

        - namespaceSelector:
            matchLabels:
              platform.banking.io/application: banking

---

################################################################################
# Default Backend Access
################################################################################

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-backend

  namespace: ingress-nginx

spec:

  podSelector:
    matchLabels:
      app.kubernetes.io/name: default-backend

  policyTypes:
    - Ingress

  ingress:

    - from:

        - podSelector:
            matchLabels:
              app.kubernetes.io/component: controller

      ports:

        - protocol: TCP
          port: 8080

---

################################################################################
# Allow Controller -> Kubernetes API
################################################################################

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: kube-api

  namespace: ingress-nginx

spec:

  podSelector:
    matchLabels:
      app.kubernetes.io/component: controller

  policyTypes:
    - Egress

  egress:

    - to:

        - ipBlock:
            cidr: 0.0.0.0/0

      ports:

        - protocol: TCP
          port: 443
          