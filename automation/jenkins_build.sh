#!/bin/bash

function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" == "$1"; }

# Jenkins build steps
for ARCH in $ARCHS
do
	for PYTHON_VERSION in $PYTHON_VERSIONS
	do
		base_version=${PYTHON_VERSION%.*}
		# Must set DEBIAN_BUILD_TAG if want to build from Debian Jessie (for OpenSSL 1.0)
		if [ -z "$DEBIAN_BUILD_TAG" ]; then
			debian_tag='stretch'
		else
			debian_tag='jessie'
		fi

		# Must set ALPINE_BUILD_TAG if want to build from Alpine Linux 3.8 (for OpenSSL 1.0)
		if [ -z "$ALPINE_BUILD_TAG" ]; then
			alpine_tag='latest'
		else
			alpine_tag='3.8'
		fi

		case "$ARCH" in
			'armv6hf')
				base_image="balenalib/rpi-raspbian:$debian_tag"
				template='Dockerfile.debian.tpl'
			;;
			'armv7hf')
				base_image="balenalib/armv7hf-debian:$debian_tag"
				template='Dockerfile.debian.tpl'
			;;
			'armel')
				base_image="balenalib/armv5e-debian:$debian_tag"
				template='Dockerfile.debian.tpl'
			;;
			'aarch64')
				base_image="balenalib/aarch64-debian:$debian_tag"
				template='Dockerfile.debian.tpl'
			;;
			'i386')
				base_image="balenalib/i386-debian:$debian_tag"
				template='Dockerfile.debian.tpl'
			;;
			'amd64')
				base_image="balenalib/amd64-debian:$debian_tag"
				template='Dockerfile.debian.tpl'
			;;
			'alpine-armv6hf')
				base_image="balenalib/rpi-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
			'alpine-i386')
				base_image="balenalib/i386-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
			'alpine-amd64')
				base_image="balenalib/amd64-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
			'alpine-aarch64')
				base_image="balenalib/aarch64-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
			'alpine-armv7hf')
				base_image="balenalib/armv7hf-alpine:$alpine_tag"
				template='Dockerfile.alpine.tpl'
			;;
		esac
		sed -e s~#{FROM}~$base_image~g $template > Dockerfile
		chmod +x build.sh
		docker build -t python-$ARCH-builder .
		
		docker run --rm -e ARCH=$ARCH \
						-e ACCESS_KEY=$ACCESS_KEY \
						-e SECRET_KEY=$SECRET_KEY \
						-e BUCKET_NAME=$BUCKET_NAME python-$ARCH-builder bash -x build.sh $PYTHON_VERSION
	done
done

# Clean up after every run
docker rmi -f python-$ARCH-builder
