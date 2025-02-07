import Flutter
import UIKit
import Photos

public class SwiftFlutterGalleryPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let stream = FlutterEventChannel(name: "flutter_gallery_plugin/data", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterGalleryPlugin()
        stream.setStreamHandler(instance)
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        self.getPhotoData()
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func onResolved(path: String, location: CLLocation, time: Double) {
        guard let eventSink = eventSink else {
            return
        }

        let locationData = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude]

        eventSink(["path": path,
                    "location": locationData, 
                    "time": time]
                );
    }

    public func closeSink() {
        guard let eventSink = eventSink else {
            return
        }

        eventSink(nil)
    }

    func getPhotoData() {
        DispatchQueue.main.async {
            let assets = self.fetchPhotos()
            let assetCount = assets.count;
            var processedCount : Int = 0;
            assets.enumerateObjects({
                (asset, index, stop) in
                        self.getPhotoPath(
                            asset: asset,
                            callback: {
                                (path) -> () in
                                processedCount += 1
                                let location = asset.location ?? CLLocation(latitude: 0.0, longitude: 0.0)
                                let time = asset.creationDate ?? Date()
                                let timestamp = time.timeIntervalSince1970
                                self.onResolved(path: path, location: location, time: timestamp)
                                if(processedCount == assetCount) {
                                    self.closeSink()
                                }
                            }
                        )
            })
        }
    }

    func fetchPhotos() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
    }

    func getPhotoPath(asset: PHAsset, callback: @escaping (String)->()) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()

        options.isNetworkAccessAllowed = true
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
        options.resizeMode = PHImageRequestOptionsResizeMode.exact

        imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: 128, height: 128),
            contentMode: PHImageContentMode.aspectFit,
            options: options,
            resultHandler: {
                (image, info) in
                callback(self.storeThumbnail(image: image))
            }
        )
    }

    func storeThumbnail(image: UIImage?) -> String {
        let fileName = String(format: "image_picker_%@.jpg", ProcessInfo.processInfo.globallyUniqueString)
        let filePath = NSString.path(withComponents: [NSTemporaryDirectory(), fileName])

        FileManager.default.createFile(
            atPath: filePath,
            contents: image?.jpegData(compressionQuality: CGFloat(0.4)),
            attributes: [:]
        )

        return filePath
    }
}
