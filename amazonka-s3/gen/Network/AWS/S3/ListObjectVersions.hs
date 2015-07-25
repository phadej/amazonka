{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE OverloadedStrings  #-}
{-# LANGUAGE RecordWildCards    #-}
{-# LANGUAGE TypeFamilies       #-}

{-# OPTIONS_GHC -fno-warn-unused-binds   #-}
{-# OPTIONS_GHC -fno-warn-unused-matches #-}

-- Derived from AWS service descriptions, licensed under Apache 2.0.

-- |
-- Module      : Network.AWS.S3.ListObjectVersions
-- Copyright   : (c) 2013-2015 Brendan Hay
-- License     : Mozilla Public License, v. 2.0.
-- Maintainer  : Brendan Hay <brendan.g.hay@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
--
-- Returns metadata about all of the versions of objects in a bucket.
--
-- <http://docs.aws.amazon.com/AmazonS3/latest/API/ListObjectVersions.html>
module Network.AWS.S3.ListObjectVersions
    (
    -- * Request
      ListObjectVersions
    -- ** Request constructor
    , listObjectVersions
    -- ** Request lenses
    , lovKeyMarker
    , lovPrefix
    , lovEncodingType
    , lovVersionIdMarker
    , lovMaxKeys
    , lovDelimiter
    , lovBucket

    -- * Response
    , ListObjectVersionsResponse
    -- ** Response constructor
    , listObjectVersionsResponse
    -- ** Response lenses
    , lovrsNextVersionIdMarker
    , lovrsKeyMarker
    , lovrsPrefix
    , lovrsDeleteMarkers
    , lovrsEncodingType
    , lovrsCommonPrefixes
    , lovrsVersions
    , lovrsName
    , lovrsNextKeyMarker
    , lovrsVersionIdMarker
    , lovrsMaxKeys
    , lovrsIsTruncated
    , lovrsDelimiter
    , lovrsStatus
    ) where

import           Network.AWS.Pager
import           Network.AWS.Prelude
import           Network.AWS.Request
import           Network.AWS.Response
import           Network.AWS.S3.Types

-- | /See:/ 'listObjectVersions' smart constructor.
--
-- The fields accessible through corresponding lenses are:
--
-- * 'lovKeyMarker'
--
-- * 'lovPrefix'
--
-- * 'lovEncodingType'
--
-- * 'lovVersionIdMarker'
--
-- * 'lovMaxKeys'
--
-- * 'lovDelimiter'
--
-- * 'lovBucket'
data ListObjectVersions = ListObjectVersions'
    { _lovKeyMarker       :: !(Maybe Text)
    , _lovPrefix          :: !(Maybe Text)
    , _lovEncodingType    :: !(Maybe EncodingType)
    , _lovVersionIdMarker :: !(Maybe Text)
    , _lovMaxKeys         :: !(Maybe Int)
    , _lovDelimiter       :: !(Maybe Char)
    , _lovBucket          :: !BucketName
    } deriving (Eq,Show,Data,Typeable,Generic)

-- | 'ListObjectVersions' smart constructor.
listObjectVersions :: BucketName -> ListObjectVersions
listObjectVersions pBucket_ =
    ListObjectVersions'
    { _lovKeyMarker = Nothing
    , _lovPrefix = Nothing
    , _lovEncodingType = Nothing
    , _lovVersionIdMarker = Nothing
    , _lovMaxKeys = Nothing
    , _lovDelimiter = Nothing
    , _lovBucket = pBucket_
    }

-- | Specifies the key to start with when listing objects in a bucket.
lovKeyMarker :: Lens' ListObjectVersions (Maybe Text)
lovKeyMarker = lens _lovKeyMarker (\ s a -> s{_lovKeyMarker = a});

-- | Limits the response to keys that begin with the specified prefix.
lovPrefix :: Lens' ListObjectVersions (Maybe Text)
lovPrefix = lens _lovPrefix (\ s a -> s{_lovPrefix = a});

-- | FIXME: Undocumented member.
lovEncodingType :: Lens' ListObjectVersions (Maybe EncodingType)
lovEncodingType = lens _lovEncodingType (\ s a -> s{_lovEncodingType = a});

-- | Specifies the object version you want to start listing from.
lovVersionIdMarker :: Lens' ListObjectVersions (Maybe Text)
lovVersionIdMarker = lens _lovVersionIdMarker (\ s a -> s{_lovVersionIdMarker = a});

-- | Sets the maximum number of keys returned in the response. The response
-- might contain fewer keys but will never contain more.
lovMaxKeys :: Lens' ListObjectVersions (Maybe Int)
lovMaxKeys = lens _lovMaxKeys (\ s a -> s{_lovMaxKeys = a});

-- | A delimiter is a character you use to group keys.
lovDelimiter :: Lens' ListObjectVersions (Maybe Char)
lovDelimiter = lens _lovDelimiter (\ s a -> s{_lovDelimiter = a});

-- | FIXME: Undocumented member.
lovBucket :: Lens' ListObjectVersions BucketName
lovBucket = lens _lovBucket (\ s a -> s{_lovBucket = a});

instance AWSPager ListObjectVersions where
        page rq rs
          | stop (rs ^. lovrsIsTruncated) = Nothing
          | isNothing (rs ^. lovrsNextKeyMarker) &&
              isNothing (rs ^. lovrsNextVersionIdMarker)
            = Nothing
          | otherwise =
            Just $ rq & lovKeyMarker .~ rs ^. lovrsNextKeyMarker
              &
              lovVersionIdMarker .~ rs ^. lovrsNextVersionIdMarker

instance AWSRequest ListObjectVersions where
        type Sv ListObjectVersions = S3
        type Rs ListObjectVersions =
             ListObjectVersionsResponse
        request = get
        response
          = receiveXML
              (\ s h x ->
                 ListObjectVersionsResponse' <$>
                   (x .@? "NextVersionIdMarker") <*> (x .@? "KeyMarker")
                     <*> (x .@? "Prefix")
                     <*> (may (parseXMLList "DeleteMarker") x)
                     <*> (x .@? "EncodingType")
                     <*> (may (parseXMLList "CommonPrefixes") x)
                     <*> (may (parseXMLList "Version") x)
                     <*> (x .@? "Name")
                     <*> (x .@? "NextKeyMarker")
                     <*> (x .@? "VersionIdMarker")
                     <*> (x .@? "MaxKeys")
                     <*> (x .@? "IsTruncated")
                     <*> (x .@? "Delimiter")
                     <*> (pure (fromEnum s)))

instance ToHeaders ListObjectVersions where
        toHeaders = const mempty

instance ToPath ListObjectVersions where
        toPath ListObjectVersions'{..}
          = mconcat ["/", toText _lovBucket]

instance ToQuery ListObjectVersions where
        toQuery ListObjectVersions'{..}
          = mconcat
              ["key-marker" =: _lovKeyMarker,
               "prefix" =: _lovPrefix,
               "encoding-type" =: _lovEncodingType,
               "version-id-marker" =: _lovVersionIdMarker,
               "max-keys" =: _lovMaxKeys,
               "delimiter" =: _lovDelimiter, "versions"]

-- | /See:/ 'listObjectVersionsResponse' smart constructor.
--
-- The fields accessible through corresponding lenses are:
--
-- * 'lovrsNextVersionIdMarker'
--
-- * 'lovrsKeyMarker'
--
-- * 'lovrsPrefix'
--
-- * 'lovrsDeleteMarkers'
--
-- * 'lovrsEncodingType'
--
-- * 'lovrsCommonPrefixes'
--
-- * 'lovrsVersions'
--
-- * 'lovrsName'
--
-- * 'lovrsNextKeyMarker'
--
-- * 'lovrsVersionIdMarker'
--
-- * 'lovrsMaxKeys'
--
-- * 'lovrsIsTruncated'
--
-- * 'lovrsDelimiter'
--
-- * 'lovrsStatus'
data ListObjectVersionsResponse = ListObjectVersionsResponse'
    { _lovrsNextVersionIdMarker :: !(Maybe Text)
    , _lovrsKeyMarker           :: !(Maybe Text)
    , _lovrsPrefix              :: !(Maybe Text)
    , _lovrsDeleteMarkers       :: !(Maybe [DeleteMarkerEntry])
    , _lovrsEncodingType        :: !(Maybe EncodingType)
    , _lovrsCommonPrefixes      :: !(Maybe [CommonPrefix])
    , _lovrsVersions            :: !(Maybe [ObjectVersion])
    , _lovrsName                :: !(Maybe BucketName)
    , _lovrsNextKeyMarker       :: !(Maybe Text)
    , _lovrsVersionIdMarker     :: !(Maybe Text)
    , _lovrsMaxKeys             :: !(Maybe Int)
    , _lovrsIsTruncated         :: !(Maybe Bool)
    , _lovrsDelimiter           :: !(Maybe Char)
    , _lovrsStatus              :: !Int
    } deriving (Eq,Show,Data,Typeable,Generic)

-- | 'ListObjectVersionsResponse' smart constructor.
listObjectVersionsResponse :: Int -> ListObjectVersionsResponse
listObjectVersionsResponse pStatus_ =
    ListObjectVersionsResponse'
    { _lovrsNextVersionIdMarker = Nothing
    , _lovrsKeyMarker = Nothing
    , _lovrsPrefix = Nothing
    , _lovrsDeleteMarkers = Nothing
    , _lovrsEncodingType = Nothing
    , _lovrsCommonPrefixes = Nothing
    , _lovrsVersions = Nothing
    , _lovrsName = Nothing
    , _lovrsNextKeyMarker = Nothing
    , _lovrsVersionIdMarker = Nothing
    , _lovrsMaxKeys = Nothing
    , _lovrsIsTruncated = Nothing
    , _lovrsDelimiter = Nothing
    , _lovrsStatus = pStatus_
    }

-- | Use this value for the next version id marker parameter in a subsequent
-- request.
lovrsNextVersionIdMarker :: Lens' ListObjectVersionsResponse (Maybe Text)
lovrsNextVersionIdMarker = lens _lovrsNextVersionIdMarker (\ s a -> s{_lovrsNextVersionIdMarker = a});

-- | Marks the last Key returned in a truncated response.
lovrsKeyMarker :: Lens' ListObjectVersionsResponse (Maybe Text)
lovrsKeyMarker = lens _lovrsKeyMarker (\ s a -> s{_lovrsKeyMarker = a});

-- | FIXME: Undocumented member.
lovrsPrefix :: Lens' ListObjectVersionsResponse (Maybe Text)
lovrsPrefix = lens _lovrsPrefix (\ s a -> s{_lovrsPrefix = a});

-- | FIXME: Undocumented member.
lovrsDeleteMarkers :: Lens' ListObjectVersionsResponse [DeleteMarkerEntry]
lovrsDeleteMarkers = lens _lovrsDeleteMarkers (\ s a -> s{_lovrsDeleteMarkers = a}) . _Default . _Coerce;

-- | Encoding type used by Amazon S3 to encode object keys in the response.
lovrsEncodingType :: Lens' ListObjectVersionsResponse (Maybe EncodingType)
lovrsEncodingType = lens _lovrsEncodingType (\ s a -> s{_lovrsEncodingType = a});

-- | FIXME: Undocumented member.
lovrsCommonPrefixes :: Lens' ListObjectVersionsResponse [CommonPrefix]
lovrsCommonPrefixes = lens _lovrsCommonPrefixes (\ s a -> s{_lovrsCommonPrefixes = a}) . _Default . _Coerce;

-- | FIXME: Undocumented member.
lovrsVersions :: Lens' ListObjectVersionsResponse [ObjectVersion]
lovrsVersions = lens _lovrsVersions (\ s a -> s{_lovrsVersions = a}) . _Default . _Coerce;

-- | FIXME: Undocumented member.
lovrsName :: Lens' ListObjectVersionsResponse (Maybe BucketName)
lovrsName = lens _lovrsName (\ s a -> s{_lovrsName = a});

-- | Use this value for the key marker request parameter in a subsequent
-- request.
lovrsNextKeyMarker :: Lens' ListObjectVersionsResponse (Maybe Text)
lovrsNextKeyMarker = lens _lovrsNextKeyMarker (\ s a -> s{_lovrsNextKeyMarker = a});

-- | FIXME: Undocumented member.
lovrsVersionIdMarker :: Lens' ListObjectVersionsResponse (Maybe Text)
lovrsVersionIdMarker = lens _lovrsVersionIdMarker (\ s a -> s{_lovrsVersionIdMarker = a});

-- | FIXME: Undocumented member.
lovrsMaxKeys :: Lens' ListObjectVersionsResponse (Maybe Int)
lovrsMaxKeys = lens _lovrsMaxKeys (\ s a -> s{_lovrsMaxKeys = a});

-- | A flag that indicates whether or not Amazon S3 returned all of the
-- results that satisfied the search criteria. If your results were
-- truncated, you can make a follow-up paginated request using the
-- NextKeyMarker and NextVersionIdMarker response parameters as a starting
-- place in another request to return the rest of the results.
lovrsIsTruncated :: Lens' ListObjectVersionsResponse (Maybe Bool)
lovrsIsTruncated = lens _lovrsIsTruncated (\ s a -> s{_lovrsIsTruncated = a});

-- | FIXME: Undocumented member.
lovrsDelimiter :: Lens' ListObjectVersionsResponse (Maybe Char)
lovrsDelimiter = lens _lovrsDelimiter (\ s a -> s{_lovrsDelimiter = a});

-- | FIXME: Undocumented member.
lovrsStatus :: Lens' ListObjectVersionsResponse Int
lovrsStatus = lens _lovrsStatus (\ s a -> s{_lovrsStatus = a});
